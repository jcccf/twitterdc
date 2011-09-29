import numpy as np
from mpl_toolkits.mplot3d import axes3d
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import LogNorm
from matplotlib.backends.backend_pdf import PdfPages
from collections import defaultdict
from matplotlib.ticker import LogLocator, LogFormatter 

d = defaultdict(int)
d1 = defaultdict(int)
d2 = defaultdict(int)

# Output Plots
pp = PdfPages('../data/images/b.pdf')

n = 500
for i in range(10,31):
  
  print "Doing for %d" % i
  f = open("../data/500_%03d_rur_outdegrees.txt" % i)
  
  rec_count, unr_count, both, neither = 0, 0, 0, 0
  
  for l in f:
    sp = l.split()
    d[(float(sp[1]), float(sp[2]), float(sp[3]))] += 1
    if float(sp[1]) > 0 and float(sp[2]) == 0 and float(sp[3]) == 0:
      rec_count += 1
    elif float(sp[1]) == 0 and (float(sp[2]) > 0 or float(sp[3]) > 0):
      unr_count += 1
    elif float(sp[1]) > 0 and (float(sp[2]) > 0 or float(sp[3]) > 0):
      both += 1
    else:
      neither += 1
      
  print "Rec %d Unr %d Both %d Neither %d" % (rec_count, unr_count, both, neither)

  xp, yp, zp, ap = [], [], [], []
  for k, v in d.iteritems():
    d1[(k[0],k[1])] += v
    d2[(k[0],k[2])] += v
    if v > 100:
      xp.append(k[1])
      yp.append(k[2])
      zp.append(k[0])
      ap.append(float(v))
  
  xp1, yp1, zp1 = [], [], []  
  for k, v in d1.iteritems():
    if k[0] < 80 and k[1] < 80:
      xp1.append(k[0])
      yp1.append(k[1])
      zp1.append(float(v))
  
  xp2, yp2, zp2 = [], [], []  
  for k, v in d2.iteritems():
    if k[0] < 80 and k[1] < 80:
      xp2.append(k[0])
      yp2.append(k[1])
      zp2.append(float(v))



  plt.clf()
  fig = plt.figure()
  ax = fig.add_subplot(111)
  plt.scatter(xp1, yp1, c=zp1, cmap=cm.jet, s=14, linewidth=0.0)
  #plt.hexbin(xp1, yp1, C=zp1, gridsize=80, cmap=cm.jet, bins=None)
  plt.axis([0, 80, 0, 80])
  ax.set_xlabel('# Reciprocated Edges')
  ax.set_ylabel('# Unreciprocated Edges (you\'re not replied to)')
  ax.set_title("n = %d, k = %d" % (n,i))
  cb = plt.colorbar()
  cb.set_label('Count')
  pp.savefig()

  plt.clf()
  fig = plt.figure()
  ax = fig.add_subplot(111)
  plt.scatter(xp2, yp2, c=zp2, cmap=cm.jet, s=14, linewidth=0.0)
  #plt.hexbin(xp2, yp2, C=zp2, gridsize=80, cmap=cm.jet, bins=None)
  plt.axis([0, 80, 0, 80])
  ax.set_xlabel('# Reciprocated Edges')
  ax.set_ylabel('# Unreciprocated Edges (you don\'t reply)')
  ax.set_title("n = %d, k = %d" % (n,i))
  cb = plt.colorbar()
  cb.set_label('Count')
  pp.savefig()

  plt.clf()
  fig = plt.figure()
  #ax = fig.add_subplot(111, projection='3d') # Good but plt.clf() stops working
  #ax = fig.gca(projection='3d') # Best
  ax = axes3d.Axes3D(fig) # Better
  p = ax.scatter(xp, yp, zp, c=ap, alpha=0.9, cmap=cm.jet, linewidth=0.0, norm=LogNorm())
    #norm = LogNorm()
  ax.set_zlabel('# Reciprocated Edges')
  ax.set_xlabel('# Unrec (you\'re not replied to)')
  ax.set_ylabel('# Unrec (you don\'t reply)')
  ax.set_title("n = %d, k = %d (Every point has frequency >=100)" % (n,i))
  l_f = LogFormatter(10, labelOnlyBase=False)
  l_l = LogLocator(base=10, subs=[0.2, 0.4, 0.6, 0.8, 1.0], numdecs=4)
  cb = fig.colorbar(p, format=l_f, ticks=l_l, shrink=0.8)
  # cb.dist = 15 # Set zoom
  #pp.savefig()
  ax.azim = 200
  ax.elev = 15
  plt.savefig("../pydata/images/%d_%d.eps" % (n,i))
  pp.savefig()

# Close the PDF
pp.close()

#plt.show()