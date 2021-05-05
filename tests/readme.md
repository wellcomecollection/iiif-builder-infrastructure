# Search Test

Test script for search service performance.

## Process

* Use the "imfeelinglucky" endpoint to get random bnumber, 
  * for each result, checks to see if there is `/v1/text/{bnum}` result
  * if so, grabs `5` random words from the text
  * add bnumber and work to dictionary (`{"bnumber": ["word", "word2"]}`)
* iterate until there are have `10` bnumbers with associated words.
* make async requests to `/search/v1/{bnum}?q={word}` with `5` workers to simulate multiple requests.

## Config

The following flags can be passed (use `python main.py --help` to see description):

* `--bnumbers` - Number of bnumbers to find. (default = 10)
* `--terms` - Number of terms per bnumber, note that only terms of 3 letters or more will be used so could be less. (default = 5)
* `--workers` - Number of consecutive workers to use for making requests. (default = 5)

## Running Test

### Local

To run the tests locally, use:

```bash
# Install dependencies
pip install -r requirements.txt

# run with defaults
python main.py 

# or specify values
python main.py --bnumbers 40 --terms 8 --workers 10
```

### Docker

You can run these tests using docker:

```bash
# build
docker build . -t search-test:local 

# run with defaults
docker run --rm -it search-test:local

# or specify values
docker run --rm -it search-test:local --bnumbers 40 --terms 8 --workers 10
```