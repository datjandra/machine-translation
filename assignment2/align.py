#!/usr/bin/env python
import optparse
import sys
from collections import defaultdict
import numpy
import cPickle



def dice_compute(bitext):
	sys.stderr.write("Training with Dice's coefficient...")
	f_count = defaultdict(int)
	e_count = defaultdict(int)
	fe_count = defaultdict(int)
	for (n, (f, e)) in enumerate(bitext):
	  for f_j in set(f):
		f_count[f_j] += 1
		for e_i in set(e):
		  fe_count[(f_j,e_i)] += 1
	  for e_i in set(e):
		e_count[e_i] += 1
	  if n % 500 == 0:
		sys.stderr.write(".")
	
	dice = defaultdict(int)
	for (k, (f_j, e_i)) in enumerate(fe_count.keys()):
	  dice[(f_j,e_i)] = 2.0 * fe_count[(f_j, e_i)] / (f_count[f_j] + e_count[e_i])
	  if k % 5000 == 0:
		sys.stderr.write(".")
	sys.stderr.write("\n")
	return dice

def dice_align(bitext,model,threshold=0.5):
	alignments=[]
	#Print alignment above threshold
	for si,(f, e) in enumerate(bitext):
		alignmentsi=[]
		for (i, f_i) in enumerate(f): 
			for (j, e_j) in enumerate(e):
				if model[(f_i,e_j)] >= threshold:
					alignmentsi.append((i,j))
		alignments.append(alignmentsi)
	return alignments

def model12_compute(bitext):
	# 1:{initialize t(f|e) uniformly or from other training }
	# 2: while not converged do
	# 3: 	for all words e_i in e and for all words f_j in f : count(f_j , e_i ) = 0
	# 4: 	for all sentence pairs e_s,f_s in (e,f) do
	# 5: 	   {compute normalization -- total_s(j) is the normalizing constant or partition function: #total_s[j]=sum(i=0..length(e)) t(f_j|e_i)*q(j,i,lf,le)}
	# 6:   	   for all positions j in f_s do
	# 7:   	       total_s (f_j) = 0
	# 8:   	       for all positions i in e_s do
	# 9:  	           total_s (f_j) += t(f_j|e_i) * q(j|i,lf,le)
	# 10:  	       end for
	# 11:  	   end for
	# 12:  	   {collect counts }
	# 13:  	   for all positions j in f_s do
	# 14:  	       for all positions i in e_s do
	# 15:				{Model 1}
	# 16:				count(f_j,e_i) += ( t(f_j|e_i) * q(j|i,lf,le) ) / total_s(j)
	# 17:				total(e_i) += ( t(f_j|e_i) * q(j|i,lf,le) ) / total_s(j)
	# 18:				{Model 2}
	# 19:				count(j,i,lf,le) += ( t(f_j|e_i) * q(j|i,lf,le) ) / total_s(j)
	# 20:				total(i,lf,le) += ( t(f_j|e_i) * q(j|i,lf,le) ) / total_s(j)
	# 21:  	       end for
	# 22:  	   end for
	# 23: 	end for
	# 24: 	{estimate probabilities }
	# 25: 	{Model 1}
	# 26: 	for all words f_j,e_i in (f,e) do
	# 27:  		t(f_j|e_i) = count(f_j ,e_i) / total(e_i)
	# 28:  	end for
	# 29: 	{Model 2}
	# 30: 	for all positions (j,i) and lengths (lf,le) in (f1)
	# 31:  	    q(j|i,lf,le)= count(j,i,lf,le) / total(i,lf,le)
	# 32:  	end for
	# 33: until convergence
	
	#{initialize t(f|e) uniformly or from other training }
	
	initial_prob=0.5
	t=defaultdict(float)
	q=defaultdict(float)
	converged=False
	iteration=0
	while not converged:
		print >>sys.stderr,"EM iteration #%d..."%iteration
		count_t=defaultdict(int)
		total_t=defaultdict(int)
		count_q=defaultdict(int)
		total_q=defaultdict(int)
		#Expect
		for (n, (f, e)) in enumerate(bitext):
			#{compute normalization }
			total_s=numpy.zeros([len(f)],'float')
			lf=len(f)
			le=len(e)
			for j,f_j in enumerate(f):
				#total_s[j]=sum(i=0..length(e)) q()
				for i,e_i in enumerate(e):
					m1key=(f_j,e_i)
					m2key=(j,i,lf,le)
					if (not iteration):
						#Model 1 Initialization 
						if (not t.has_key(m1key)):
							t[m1key]=initial_prob
						#Model 2 Initialization    
						if (not q.has_key(m2key)):
							q[m2key]=initial_prob
					#{compute normalization -- total_s(j) is the normalizing constant or partition function: #total_s[j]=sum(i=0..length(e)) t(f_j|e_i)*q(j,i,lf,le)}
					#total_s[j]+= *** YOUR CODE HERE ***
					total_s[j] += t[m1key] * q[m2key]
			#{collect counts }
			for j,f_j in enumerate(f):
				for i,e_i in enumerate(e):
					m1key=(f_j,e_i)
					m2key=(j,i,lf,le)
					#Model1
					# value= *** YOUR CODE HERE ***
					value = (t[m1key] * q[m2key]) / total_s[j]

					#Model1: count_t and total_t
					count_t[m1key] += value
					total_t[e_i] += value
					#Model2: count_q and total_q
					# *** YOUR CODE HERE ***
					count_q[m2key] += value
					m3key=(i,lf,le)
					total_q[m3key] += value
		#Maximize
		#{estimate probabilities }
		t_old=t.copy()
		margin_err_t=0
		for f,e in t.keys():
			# t[(f,e)]= *** YOUR CODE HERE ***
			t[(f,e)] = count_t[(f,e)] / total_t[e]
			margin_err_t+=numpy.power(t[(f,e)]-t_old[(f,e)],2)
		
		q_old=q.copy()
		margin_err_q=0
		for j,i,lf,le in q.keys():
			# q[(j,i,lf,le)]= *** YOUR CODE HERE *** 
			q[(j,i,lf,le)] = count_q[(j,i,lf,le)] / total_q[(i,lf,le)]
			margin_err_q+=numpy.power(q[(j,i,lf,le)]-q_old[(j,i,lf,le)],2)    
		
		iteration+=1
		
		print >>sys.stderr,"Squared Difference t:%0.6f q:%0.6f"%(margin_err_t,margin_err_q)
		if (margin_err_t<1 and margin_err_q<1 ):
			converged=True

		if (iteration>=40):
			break
	
	return t,q

def model12_align(bitext,model12,threshold):
	model1,model2=model12
	#save alignment above threshold
	alignments=[]
	for (f, e) in bitext:
		align_i=[]
		le=len(e)
		lf=len(f)
		for (j, f_j) in enumerate(f):	
			probs=numpy.zeros([le],'float')
			#*** YOUR CODE HERE ***
			# for (i, e_i) in enumerate(e):
			# 		probs[i]=model1...
			for (i, e_i) in enumerate(e):
				m1key=(f_j, e_i)
				m2key=(j, i, lf, le)
				probs[i] = model1[m1key] * model2[m2key]
			if (max(probs)>threshold):
				align_i.append((j,numpy.argmax(probs)))
		alignments.append(align_i)
	  
	return alignments

def GROW_DIAG(bitext,f2e,e2f,alignments,neighbouring):
	#iterate until no new points added
	foreign,english=bitext
	union_al=set(f2e).union(set([(f,e) for e,f in e2f]))
	for ewi,ew in enumerate(english):
		for fwi,fw in enumerate(foreign):
#            if ( e aligned with f )
			if(alignments.intersection(set([(fwi,ewi)]))):
#                for each neighboring point ( e-new, f-new ):
				 for fnew,enew in [(fwi+xdesp,ewi+ydesp) for xdesp,ydesp in neighbouring]:
#                    if ( ( e-new not aligned or f-new not aligned ) and ( e-new, f-new ) in union( e2f, f2e ) )
					if ((not len(set([fai for fai,eai in alignments]).intersection(set([fnew]))) or
						not len(set([eai for fai,eai in alignments]).intersection(set([enew])))) and
						len(union_al.intersection([(fnew,enew)]))):
#                        add alignment point ( e-new, f-new )
						alignments.add((fnew,enew))

def FINAL(bitext,a,alignments):
	foreign,english=bitext
	for ewi,ew in enumerate(english):
		for fwi,fw in enumerate(foreign):
#           if ( ( e-new not aligned OR f-new not aligned ) and ( e-new, f-new ) in a )
			if ((not len(set([fai for fai,eai in alignments]).intersection(set([fwi]))) or 
				 not len(set([eai for fai,eai in alignments]).intersection(set([ewi])))) and
				len(a.intersection([(fwi,ewi)]))):
#               add alignment point ( e-new, f-new )
				alignments.add((fwi,ewi)) 

def FINAL_AND(bitext,a,alignments):
	foreign,english=bitext
	for ewi,ew in enumerate(english):
		for fwi,fw in enumerate(foreign):
#           if ( ( e-new not aligned AND f-new not aligned ) and ( e-new, f-new ) in a )
			if ((not len(set([fai for fai,eai in alignments]).intersection(set([fwi]))) and 
				 not len(set([eai for fai,eai in alignments]).intersection(set([ewi])))) and
				len(a.intersection([(fwi,ewi)]))):
#               add alignment point ( e-new, f-new )
				alignments.add((fwi,ewi))      
		 
def GROW_DIAG_FINAL_AND(bitext_fe,f2e,e2f,final="FINAL"):
	neighboring = ((-1,0),(0,-1),(1,0),(0,1),(-1,-1),(-1,1),(1,-1),(1,1))
	alignments=[]
	
	for fi,f2ei in enumerate(f2e):
		e2fi=e2f[fi]
		alignmentsi=set(f2ei).intersection(set([(y,x) for x,y in e2fi]))
		GROW_DIAG(bitext_fe[fi],f2ei,e2fi,alignmentsi,neighboring);
		#When alignment data is small and there exist sparsity problems, it can be harmful
		if (final=="FINAL"):
			FINAL(bitext_fe[fi],set([(y,x) for x,y in e2fi]),alignmentsi);
			FINAL(bitext_fe[fi],set(f2ei),alignmentsi);
		elif (final=="FINAL-AND"):
			FINAL_AND(bitext_fe[fi],set([(y,x) for x,y in e2fi]),alignmentsi);
			FINAL_AND(bitext_fe[fi],set(f2ei),alignmentsi);
		alignments.append(alignmentsi)

	return alignments


def printAlignments(alignnents):

	for alignmentsi in alignments:
		sys.stdout.write(" ".join(["%d-%d"%(f,e) for f,e in sorted(alignmentsi)]))
		sys.stdout.write("\n");
	pass

	  
if __name__=="__main__":
	
	optparser = optparse.OptionParser()
	optparser.add_option("-d", "--data", dest="train", default="bible", help="Data filename prefix (default=bible)")
	optparser.add_option("-e", "--english", dest="english", default="e", help="Suffix of English filename (default=e)")
	optparser.add_option("-f", "--foreign", dest="foreign", default="f", help="Suffix of French filename (default=f)")
	optparser.add_option("-t", "--threshold", dest="threshold", default=0.025, type="float", help="Threshold for considering aligment from probability")
	optparser.add_option("-n", "--num_sentences", dest="num_sents", default=sys.maxint, type="int", help="Number of sentences to use for training and alignment")
	(opts, _) = optparser.parse_args()
	f_data = "%s.%s" % (opts.train, opts.foreign)
	e_data = "%s.%s" % (opts.train, opts.english)

	bitext_fe = [[sentence.strip().split() for sentence in pair] for pair in zip(open(f_data), open(e_data))[:opts.num_sents]]
	bitext_ef = [[sentence.strip().split() for sentence in pair] for pair in zip(open(e_data), open(f_data))[:opts.num_sents]]
	# #Dice Align
	dice=dice_compute(bitext_ef)
	alignments=dice_align(bitext_fe,dice,opts.threshold)
	
	#Model 1 and 2 Align
	#F-E: bitext_aligned_fe
	model12_fe=model12_compute(bitext_fe)
	alignments=model12_align(bitext_fe,model12_fe,opts.threshold)
	bitext_aligned_fe=alignments

	#E-F: bitext_aligned_ef
	#	*** YOUR CODE HERE ***
	model12_ef = model12_compute(bitext_ef)
	alignments = model12_align(bitext_ef, model12_ef, opts.threshold)
	bitext_aligned_ef = alignments

	#Perform growing heuristic diagonal with final and
	#bitext_aligned_fe=alignments
	heuristic="FINAL" #it can be either None, "FINAL" or "FINAL-AND"
	alignments=GROW_DIAG_FINAL_AND(bitext_fe,bitext_aligned_fe,bitext_aligned_ef,heuristic)

	printAlignments(alignments)
   
