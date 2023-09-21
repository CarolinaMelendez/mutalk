Class {
	#name : 'AllTestsMethodsRunningMutantEvaluationStrategy',
	#superclass : 'MutantEvaluationStrategy',
	#category : 'MuTalk-Model-Mutant evaluation strategies',
	#package : 'MuTalk-Model',
	#tag : 'Mutant evaluation strategies'
}

{ #category : 'private' }
AllTestsMethodsRunningMutantEvaluationStrategy >> testCasesToEvaluate: aMutation for: aMutantEvaluation [
	^aMutantEvaluation testCases.
	
]
