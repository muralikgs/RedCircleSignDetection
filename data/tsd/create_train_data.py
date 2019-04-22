import os 
import random

path = './images/train/'

files = []

for r, d, f in os.walk(path):
	files.append(f)

f = files[0]
random.shuffle(f)

train = f[:720]
test = f[720:]

with open('../tsd_train.txt', 'w') as file:
	for img in train:
		file.write('./data/tsd/images/train/'+img+'\n')
	file.close()

with open('../tsd_test.txt', 'w') as file:
	for img in test:
		file.write('./data/tsd/images/train/'+img+'\n')
	file.close()

