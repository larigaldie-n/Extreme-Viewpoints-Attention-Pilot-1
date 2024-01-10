import requests
from bs4 import BeautifulSoup
import csv
import pandas as pd


def scrape_kialo(url, idx):
    req = requests.get(url)
    soup = BeautifulSoup(req.text, 'html5lib')
    claim_soup = soup.select(".selected-claim-container span")
    pros_soup = soup.select(".column-box--claims-pro h3>span")
    for pro_soup in pros_soup:
        while pro_soup.span:
            pro_soup.span.unwrap()
    cons_soup = soup.select(".column-box--claims-con h3>span")
    for con_soup in cons_soup:
        while con_soup.span:
            con_soup.span.unwrap()

    with open('data.csv', 'a', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for pro_arg in pros_soup:
            writer.writerow([idx, url, claim_soup[0].text.strip(" ."), pro_arg.text.strip(" ."), "pro", len(pro_arg.text.split())])
            idx += 1
        for con_arg in cons_soup:
            writer.writerow([idx, url, claim_soup[0].text.strip(" ."), con_arg.text.strip(" ."), "con", len(con_arg.text.split())])
            idx += 1
    return idx


# def create_js_data():
#    with open('data.csv', 'r') as f:
#        with open('data.js', 'w') as js_file:
#            js_file.write("var data = `" + f.read().encode('unicode_escape').decode("utf-8") + "`;")


if __name__ == '__main__':
    index = 1
    kialo = pd.read_csv("kialo.csv")
    for url_page in kialo.URL:
        index = scrape_kialo(url_page, index)
    # create_js_data()


