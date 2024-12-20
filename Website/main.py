from flask import Flask, render_template, request
import pandas as pd
from pathlib import Path
import uuid
import hashlib
import os, sys

app = Flask(__name__)


def data_submission(row, variable):
    if variable == "Agreement":
        return round(float(request.form.get(hashlib.sha1(row["Argument"].encode("UTF-8")).hexdigest() + "-agreement")), 5)
    elif variable == "Emotions":
        return round(float(request.form.get(hashlib.sha1(row["Argument"].encode("UTF-8")).hexdigest() + "-emotions")), 5)
    elif variable == "New":
        return int(request.form.get(hashlib.sha1(row["Argument"].encode("UTF-8")).hexdigest() + "-new"))


@app.route('/')
def index():
    return render_template("index.html", user=uuid.uuid4())


@app.route('/XP/', methods=['GET'])
def xp():
    user = request.args.get("user")
    this_folder = Path(__file__).parent.resolve()
    data_path = this_folder / "data.csv"
    rendered_path = this_folder / (
                "rendered_pages/" + user + ".csv")
    data = pd.read_csv(data_path, encoding="utf-8")
    data = data.sample(frac=1).reset_index(drop=True)
    recorded_data = data[["Index", "Topic", "Argument", "Words"]]
    recorded_data.index += 1
    recorded_data.to_csv(rendered_path, index_label="Order")
    os.utime(rendered_path, ns=(1, 1))
    return render_template("XP.html", arguments=data[["Topic", "Argument"]].values.tolist(), user=user)


@app.route('/questionnaire/', methods=['GET'])
def questionnaire():
    user = request.args.get("user")
    dict_args = dict()
    this_folder = Path(__file__).parent.resolve()
    rendered_path = this_folder / (
            "rendered_pages/" + user + ".csv")
    data = pd.read_csv(rendered_path, encoding="utf-8")
    for idx, row in data.iterrows():
        if row["Topic"] in dict_args.keys():
            dict_args[row["Topic"]].append((row["Argument"], hashlib.sha1(row["Argument"].encode("UTF-8")).hexdigest()))
        else:
            dict_args[row["Topic"]] = [(row["Argument"], hashlib.sha1(row["Argument"].encode("UTF-8")).hexdigest())]
    return render_template("questionnaire.html", user=user, arguments=dict_args)


@app.route('/ending/', methods=['POST'])
def ending():
    user = request.form.get("user")
    this_folder = Path(__file__).parent.resolve()
    rendered_path = this_folder / (
            "rendered_pages/" + user + ".csv")
    data = pd.read_csv(rendered_path, encoding="utf-8")
    data["Agreement"] = data.apply(data_submission, variable="Agreement", axis=1)
    data["Emotions"] = data.apply(data_submission, variable="Emotions", axis=1)
    data["New"] = data.apply(data_submission, variable="New", axis=1)

    data.to_csv(rendered_path, index=False)
    os.utime(rendered_path, ns=(1, 1))
    return render_template("ending.html")


@app.route('/instructions/', methods=['GET'])
def instructions():
    user = request.args.get("user")
    return render_template("instructions.html", user=user)
