#!/usr/bin/python

#HMDB xml file parser
#Metabolite data was downloaded from http://www.hmdb.ca/downloads
#03/24/2018
#Yue Hao

import sys
from xml.etree import cElementTree as ET

def main():
  file = sys.argv[1]
  tree = ET.parse(file)
  root = tree.getroot()
  for child in root:
    mname = child.find('name').text
    mid = child.find('accession').text
    printab(mid)
    printab(mname)
    for node in child.findall('.//secondary_accessions'):
        for snode in node.findall('accession'):
            printab(snode.text)
    print '\r'
    for node in child.findall('.//pathways'):
        for snode in node.getchildren():
            pname = snode.find('name').text
            print (pname)
            print '\r'

def printab(var):
    sys.stdout.write(var)
    sys.stdout.write('\t')  

if __name__ == '__main__':
  main()
