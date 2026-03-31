from typing import Optional

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent))


from app.scrapers.anthropic import AnthropicScraper
from app.database.repository import Repository


def process_anthropic_markdown(limit: Optional[int] = None) -> dict:
    scraper = AnthropicScraper()
    repo = Repository()
    
    articles = repo.get_anthropic_articles_without_markdown(limit=limit)
    processed = 0
    failed = 0
    
    for article in articles:
        markdown = scraper.url_to_markdown(article.url)
        try:
            if markdown:
                repo.update_anthropic_article_markdown(article.guid, markdown)
                processed += 1
            else:
                failed += 1
        except Exception as e:
            failed += 1
            print(f"Error processing article {article.guid}: {e}")
            continue
    
    return {
        "total": len(articles),
        "processed": processed,
        "failed": failed
    }


if __name__ == "__main__":
    result = process_anthropic_markdown()
    print(f"Total articles: {result['total']}")
    print(f"Processed: {result['processed']}")
    print(f"Failed: {result['failed']}")

# Potential fix
# One difference from process_youtube.py
# There's no __UNAVAILABLE__ marker here. If markdown conversion fails, the article just stays with markdown=None in the DB and will be retried on the next run.
# This is actually worth noting as another potential improvement — if docling consistently fails on certain URLs, the app will keep retrying them forever. Adding a marker like __FAILED__ similar to YouTube would fix this.        