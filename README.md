Projet MAD
==========

Web crawling de Wikipedia, en partant de la page concernant l'analyse de données.

Installation
------------
<pre>
  # Install dependencies
  bundle
</pre>

Usage
-----
Crawling à partir de URL, de profondeur DEPTH du parcours, avec THREAD_COUNT threads en parallèle, et écriture des données dans FILE sous la forme :
url\tmot\tfrequence\n
<pre>
  ruby crawler.rb URL FILE DEPTH THREAD_COUNT
</pre>
On peut stopper le processus sans conséquence.

Analyse des données, en prenant les WORD_COUNT mots les plus fréquents
dans tous les documents, qu'on appelle par la commande :
<pre>
  ruby analyzer.rb SRC DEST WORD_COUNT
</pre>
où SRC est le fichier à analyser, DEST le fichier dans lequel on
écrit les résultats
