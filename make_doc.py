from pylode.profiles.ontpub import OntPub
from bs4 import BeautifulSoup
from dominate.tags import *
import markdown
import pymdownx.superfences
import os.path
import shutil
import re

def make_head():
    return """
<!DOCTYPE html>
<html>
    <head>
        <title>FDRI Metadata Ontology</title>
        <script src="https://cdn.jsdelivr.net/npm/mermaid@11.6.0/dist/mermaid.min.js"></script>
        <link rel="stylesheet" href="normalize.css" />
        <link rel="stylesheet" href="styles.css" />
        <script src="toc.js"></script>
    </head>
    <body>
    <nav id="toc">
        <h2 class="notoc">Table of Contents</h2>
    </nav>
    <main>
    <h1>FDRI Metadata Ontology</h1>
"""

def fix_md_file_links(html):
    soup = BeautifulSoup(html, 'html.parser')
    for el in soup.find_all('a', attrs={'href': re.compile('\.md$')}):
        el.attrs['href'] = '#' + el.attrs['href']
    return soup.prettify()

def link_fdri_entities(soup):
    entity_map = {}
    for entity_div in soup.find_all('div', class_='entity'):
        entity_div_id = entity_div.attrs['id']
        entity_map['fdri:' + entity_div_id] = '#' + entity_div_id

    print(entity_map)
    for fdri_el in soup.find_all('code', string=re.compile('^\s*fdri:')):
        target = fdri_el.string.strip()
        if target in entity_map:
            fdri_el.name='a'
            fdri_el['class']='entity'
            fdri_el['href'] = entity_map[target]
            fdri_el.string = target
        # fdri_el.string = target
        # if target in entity_map:
        #     fdri_el.wrap(soup.new_tag('a', href=entity_map[target]))

def make_section(md_path):
    md_file = os.path.basename(md_path)
    with open(md_path, 'r', encoding='utf-8') as input_stream:
        text = input_stream.read()
    html = markdown.markdown(
        text,
        extensions=['tables', 'pymdownx.superfences'],
        extension_configs={
            "pymdownx.superfences": {
                "custom_fences": [
                    {
                        'name': 'mermaid',
                        'class': 'mermaid',
                        'format': pymdownx.superfences.fence_div_format
                    }
                ]
            }
        })
    html = fix_md_file_links(html)
    return f"""<section id="{md_file}">{html}</section>"""

def make_reference_doc():
    od = OntPub(ontology="owl/fdri-metadata.ttl")
    html = od.make_html()
    soup = BeautifulSoup(html, 'html.parser')
    content = soup.find("div", id="content")
    # Increment headers
    for header in content.find_all('h4'):
        header.name='h5'
    for header in content.find_all('h3'):
        header.name='h4'
    for header in content.find_all('h2'):
        header.name='h3'
    for header in content.find_all('h1'):
        header.name='h2'
    for content_section in content.find_all('div', recursive=False):
        content_section.unwrap()
    content.name = 'section'
    content.attrs['id'] = 'reference'
    return content.prettify()

def make_foot():
    return """
    </main>
    </body>
</html>
"""
if __name__ == '__main__':
    html = make_head()
    html += make_section('doc/introduction.md')
    html += make_section('doc/programme-catalog.md')
    html += make_section('doc/high-level-catalog-structure.md')
    html += make_section('doc/annotations.md')
    html += make_section('doc/time-series-dataset.md')
    html += make_section('doc/provenance-and-activity.md')
    html += make_section('doc/variables.md')
    html += make_section('doc/emf.md')
    html += make_section('doc/em-activities.md')
    html += make_section('doc/deployments.md')
    html += make_section('doc/sensor-system.md')
    html += make_section('doc/sensor-capabilities.md')
    html += make_section('doc/data-processing-configurations.md')
    html += make_section('doc/geospatial.md')
    html += make_reference_doc()
    html += make_foot()
    soup = BeautifulSoup(html, 'html.parser')
    link_fdri_entities(soup)
    with open('doc/html/index.html', 'w', encoding='utf-8') as output_stream:
        output_stream.write(soup.prettify())
    shutil.copyfile('doc/ogc-types.png', 'doc/html/ogc-types.png')
    shutil.copyfile('doc/sensor-things-types.png', 'doc/html/sensor-things-types.png')


