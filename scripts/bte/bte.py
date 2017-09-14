#!/usr/bin/python

import sys,BodyTextExtractor

html = open(sys.argv[1]).read()
p = BodyTextExtractor.HtmlBodyTextExtractor()
p.feed(html)
p.close()
x = p.body_text()
s = p.summary()
t = p.full_text()
print x
