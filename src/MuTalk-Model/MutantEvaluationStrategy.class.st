Class {
	#name : 'MutantEvaluationStrategy',
	#superclass : 'Object',
	#category : 'MuTalk-Model-Mutant evaluation strategies',
	#package : 'MuTalk-Model',
	#tag : 'Mutant evaluation strategies'
}

{ #category : 'evaluating' }
MutantEvaluationStrategy >> testCasesToEvaluate: aMutation for: aMutantEvaluation [
	self subclassResponsibility
]

{ #category : 'evaluating' }
MutantEvaluationStrategy >> timeoutForTestsOf: aMutantEvaluation [
	^aMutantEvaluation coverageAnalysisResult timeToRunTests * 3
]
