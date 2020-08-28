from flask import Flask
from flask import jsonify

app = Flask(__name__)


@app.route("/")
def hello():
    return "Hello World from Flask"


@app.route("/allowed")
def allowed():
    return jsonify(
        {"bafybeih6paqfqecaesxhmt4waq2umkuukxqubikyst7s47iywsp72wbtka": True}
    )


@app.route("/denied")
def denied():
    return jsonify({
        "bafybeih6paqfqecaesxhmt4waq2umkuukxqubikyst7s47iywsp72wbtka": {
            "/2020-08-14-ipfs-meetup-aug2020/": {
                "return_code": 410
            },
            "/2020-08-07-deprecating-secio/": {
                "return_code": 451
            }
        },
        "bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq": True
    })


