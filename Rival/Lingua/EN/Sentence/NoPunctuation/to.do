# https://www.google.com/search?q=estimate-sentence-breaks-without-punctuation&ie=utf-8&oe=utf-8#safe=active&q=sentence+splitter+without+punctuation

# https://stackoverflow.com/questions/27807333/sentence-annotation-in-text-without-punctuation

This would be a neat project! I don't think anyone is working on it in our group at the moment, but I see no reason why we wouldn't incorporate a patch if you make one. The biggest challenge I see is that our sentence splitter is currently entirely rule-based, and therefore these sorts of "soft" decisions are relatively hard to incorporate.

A possible solution for your case could be to use language model "end of sentence" probabilities (Three options, in no particular order: https://kheafield.com/code/kenlm/, https://code.google.com/p/berkeleylm/, http://www.speech.sri.com/projects/srilm/). Then, line ends with a sufficiently high end of sentence probability could get split as new sentences.
