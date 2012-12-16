###About

This gem implements a PageRank class and a class that allows to perform keyword ranking using the TextRank algorithm. Both were ported from the [PHP Implementation](https://github.com/crodas/textrank) by @crodas.

###Install

```
gem install graph-rank
```

###Usage

**TextRank**

> Reference: R. Mihalcea and P. Tarau, “TextRank: Bringing Order into Texts,” in Proceedings of EMNLP 2004. Association for Computational Linguistics, 2004, pp. 404–411.

```ruby
text = 'PageRank is a link analysis algorithm, named after Larry ' +
'Page and used by the Google Internet search engine, that assigns ' +
'a numerical weighting to each element of a hyperlinked set of ' +
'documents, such as the World Wide Web, with the purpose of "measuring"' +
'its relative importance within the set.'

tr = GraphRank::Keywords.new

tr.run(text).inspect

```

Optionally, you can pass the n-gram size (default = 3), as well as the damping and convergence (see PageRank) to the constructor. Finally, you can set stop words as follows:

```ruby
tr.stop_words = ["word", "another", "etc"]
```

**PageRank**

> Reference: Brin, S.; Page, L. (1998). "The anatomy of a large-scale hypertextual Web search engine". Computer Networks and ISDN Systems 30: 107–117.

```ruby

pr = GraphRank::PageRank.new

pr.add(1,2)
pr.add(1,4)
pr.add(1,5)
pr.add(4,5)
pr.add(4,1)
pr.add(4,3)
pr.add(1,3)
pr.add(3,1)
pr.add(5,1)

puts pr.calculate.inspect

# => [[1, 5.99497754810465], [3, 2.694723988738302], 
#    [5, 2.694723988738302], [4, 2.100731029131304],
#    [2, 2.100731029131304]]
```

Optionally, you can pass the damping factor (default = 0.85) and the convergence criterion (default = 0.01) as parameters to the PageRank constructor. Additionally, you can pass in an edge weight parameter to `#add` and it will be used in the PageRank calculation.