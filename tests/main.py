import aiohttp
import asyncio
import click
import random

from timeit import default_timer


def get_url_path(bnum, term):
    v1_template = "http://dds.wellcomecollection.digirati.io/search/v1/"
    return f"{v1_template}{bnum}?q={term}"


async def search_test(iterations=10, words_per_bnum=5, workers=5):
    data = {}

    async with aiohttp.ClientSession() as session:
        click.echo(
            click.style(f"Getting list of {iterations} bnumbers, {words_per_bnum} words each", fg="white", bold=True))

        while len(data.keys()) < iterations:
            candidate = await get_random_bnum(session)
            if candidate in data:
                continue

            if words := await get_random_words(session, candidate, words_per_bnum):
                click.echo(click.style(f"Using '{candidate}' ({len(data.keys()) + 1})..", fg="cyan"))
                data[candidate] = words

        await get_all_search_results(data, workers, session)


async def get_all_search_results(data, worker_count, session):
    click.echo(click.style(f"Running test with {worker_count} workers", fg="white", bold=True))
    sem = asyncio.Semaphore(worker_count)
    tasks = []

    for bnum, search_terms in data.items():
        bnum_count = 0
        for term in [s for s in search_terms if len(s) > 3]:
            bnum_count = bnum_count + 1
            task = asyncio.create_task(do_search(sem, bnum, term, bnum_count, session))
            tasks.append(task)

    await asyncio.gather(*tasks)


async def do_search(semaphore, bnum, term, bnum_count, session):
    async with semaphore:
        path = get_url_path(bnum, term)

        start = default_timer()
        async with session.get(path) as response:
            end = default_timer()
            duration = end - start

            if response.status != 200:
                click.echo(click.style(f"{bnum}:{bnum_count} - {term} returned {response.status}", fg="red"))

            color = "green"
            if duration > 10:
                color = "magenta"
            elif duration > 5:
                color = "red"
            elif duration > 2:
                color = "yellow"

            click.echo(click.style(f"{bnum}:{bnum_count} - '{term}' took {round(duration * 1000)}ms", fg=color))


async def get_random_bnum(session):
    """Use i'mfeelinglucky to get a random bnum"""
    async with session.get("https://iiif.wellcomecollection.org/service/suggest-b-number?q=imfeelinglucky") as response:
        json = await response.json()
        return json[0].get("id", "")


async def get_random_words(session, bnum, word_count=4):
    """Try to get some random words for bnumber"""
    async with session.get(f"http://iiif.wellcomecollection.org/text/v1/{bnum}") as text_response:
        if text_response.status == 404:
            return []
        all_text = await text_response.text()
        return random.sample(all_text.split(" "), word_count)


@click.command()
    @click.option("--bnumbers", default=10, help="Number of bnumbers to process")
    @click.option("--terms", default=5, help="Number of terms per bnumber")
    @click.option("--workers", default=5, help="Number of consecutive workers")
def check_iiif(bnumbers, terms, workers):
    loop = asyncio.get_event_loop()
    loop.run_until_complete(search_test(bnumbers, terms, workers))


if __name__ == '__main__':
    check_iiif()
