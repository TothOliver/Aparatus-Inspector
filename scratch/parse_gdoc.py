import re
from html.parser import HTMLParser

class MyHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.text_content = []
        self.is_script_or_style = False

    def handle_starttag(self, tag, attrs):
        if tag in ['script', 'style']:
            self.is_script_or_style = True

    def handle_endtag(self, tag):
        if tag in ['script', 'style']:
            self.is_script_or_style = False

    def handle_data(self, data):
        if not self.is_script_or_style:
            cleaned = data.strip()
            if cleaned:
                self.text_content.append(cleaned)

# Read the HTML content
html_path = r"C:\Users\johan\.gemini\antigravity\brain\8889b19d-568b-41e9-af8c-95c96998499c\.system_generated\steps\334\content.md"
with open(html_path, "r", encoding="utf-8") as f:
    html_content = f.read()

parser = MyHTMLParser()
parser.feed(html_content)

# Join and print first 3000 characters
full_text = "\n".join(parser.text_content)
print(f"Total parsed length: {len(full_text)}")
print("--- FIRST 4000 CHARACTERS ---")
print(full_text[:4000])

# Save clean text to scratch
with open("scratch/clean_gdoc.txt", "w", encoding="utf-8") as f:
    f.write(full_text)
print("\nSaved clean text to scratch/clean_gdoc.txt")
