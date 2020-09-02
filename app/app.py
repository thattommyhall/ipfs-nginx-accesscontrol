from flask import Flask, jsonify, Response

app = Flask(__name__)


@app.route("/")
def hello():
    return "Basic accesscontrol for IPFS gateways"


ALLOWED = set(
    [
        "QmZUWCpeaEFkkX972iELb2xZr8QmX2dstDuA4TN9HXSKt8",
        "bafybeih6paqfqecaesxhmt4waq2umkuukxqubikyst7s47iywsp72wbtka",
    ]
)


@app.route("/check_cid/<cid>")
def check_cid(cid):
    if cid not in ALLOWED:
        return {"denied": {cid: 410}}
    else:
        return {"allowed": {cid: True}}


@app.route("/acl")
def acl():
    return jsonify(
        {
            "denied": {
                "bafybeih6paqfqecaesxhmt4waq2umkuukxqubikyst7s47iywsp72wbtka": {
                    "/2020-08-14-ipfs-meetup-aug2020/": 410,
                    "/2020-08-07-deprecating-secio/": 451,
                },
                "bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq": 410,
            },
            "allowed": {
                "bafybeih6paqfqecaesxhmt4waq2umkuukxqubikyst7s47iywsp72wbtka": True
            },
        }
    )
