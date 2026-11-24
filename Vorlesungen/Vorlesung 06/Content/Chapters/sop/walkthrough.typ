#import "../../../Template/hszg.typ": *

== Same-Origin vs. Cross-Origin: Walkthrough

#slide(align: horizon)[
    Base-URL: `https://app.example.com:443` (`443` ist HTTPS Port)
    #table(
        columns: (auto, auto, 1fr),
        align: (left, center, left),
        table.header(
            [andere URL], [Ergebnis], [Grund]
        ),
        [`https://app.example.com:443/`], [#emoji.checkmark Same-Origin], [443 explizit geschrieben = HTTPS default],
        [`https://app.example.com:8443/`], [#emoji.crossmark Cross-Origin], [Port ist anders],
        [`http://app.example.com`], [#emoji.crossmark Cross-Origin], [Zwei Violations: `http` $eq.not$ `https` und Default Port `80` $eq.not$ `443`],
    )
]
