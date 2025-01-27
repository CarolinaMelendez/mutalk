Class {
	#name : #MutantOperator,
	#superclass : #Object,
	#category : #'MuTalk-Model-Operators'
}

{ #category : #accessing }
MutantOperator class >> allConcreteSubclasses [

	^ self allSubclasses reject: [ :ea | 
		  ea isAbstract | ea isOriginalOperator not ]
]

{ #category : #accessing }
MutantOperator class >> contents [

	"This returns only the traditional operators "


	^ (self allConcreteSubclasses collect: [ :class | class new ]) 
		  asSortedCollection: [ :elem1 :elem2 | 
		  elem1 description <= elem2 description ]
]

{ #category : #accessing }
MutantOperator class >> contentsAll [

	"This returns all operators (block based and traditional) "

	^ ((self allSubclasses reject: [ :ea | ea isAbstract ]) collect: [ 
		   :class | class new ]) asSortedCollection: [ :elem1 :elem2 | 
		  elem1 description <= elem2 description ]
]

{ #category : #accessing }
MutantOperator class >> isAbstract [
	^self subclasses isNotEmpty
]

{ #category : #testing }
MutantOperator class >> isOriginalOperator [
	^ true
]

{ #category : #'as yet unclassified' }
MutantOperator class >> recursionsDetectionStatement [

	^ RBParser parseExpression:
		  ('MuTalkInfiniteRecursionError onCount: {1}' format: { self recursionsDetectionThreshold } )
]

{ #category : #'as yet unclassified' }
MutantOperator class >> recursionsDetectionThreshold [

	"We need a big enough number"

	^ 1024
]

{ #category : #applying }
MutantOperator >> applyTo: anOldNode [

	| rewriter |
	rewriter := RBParseTreeRewriter new.
	rewriter
		replace: self expressionToReplace
		withValueFrom: [ :oNode | | aNewNode |
			aNewNode := RBParser parseRewriteExpression: self newExpression.
			aNewNode copyInContext: rewriter context ].
	rewriter executeTree: anOldNode copy.
	^ rewriter tree
]

{ #category : #printing }
MutantOperator >> description [
	self subclassResponsibility
]

{ #category : #applying }
MutantOperator >> expressionToReplace [
	self subclassResponsibility
]

{ #category : #private }
MutantOperator >> is: originalRBMethodNode equalTo: nodeThatMatches [ 
	^ nodeThatMatches formattedCode = originalRBMethodNode formattedCode
]

{ #category : #private }
MutantOperator >> isAPosibleMutatedNode: aRBMethodNode [ 
	|nodeThatMatches |
	
	nodeThatMatches := (RBParseTreeSearcher treeMatching: self newExpression
												  in: aRBMethodNode). 
	
	^ nodeThatMatches notNil and: [self is: nodeThatMatches equalTo: aRBMethodNode]
]

{ #category : #private }
MutantOperator >> isAPosibleNodeToMutate: aRBMethodNode [ 
	| nodeThatMatches |
	nodeThatMatches := RBParseTreeSearcher treeMatching: self expressionToReplace
												in: aRBMethodNode.
	
	^ nodeThatMatches notNil and: [ self is: aRBMethodNode equalTo: nodeThatMatches ]
]

{ #category : #testing }
MutantOperator >> isNodeOfMutation: posibleMutatedRBMethodNode comparingWith: originalRBMethodNode [ 
	^ (self isAPosibleNodeToMutate: originalRBMethodNode) 
		and: [ self isAPosibleMutatedNode: posibleMutatedRBMethodNode ]
]

{ #category : #private }
MutantOperator >> modifiedSourceFor: aCompiledMethod number: aNumber [ 
	"this method must be removed, it is only added because some tests send this message - Gabo"
		^self modifiedSourceFor: aCompiledMethod with: aCompiledMethod parseTree number: aNumber 
]

{ #category : #private }
MutantOperator >> modifiedSourceFor: aCompiledMethod with: aParseTree number: aNumber [

	| rewriter parser number nNode |
	rewriter := RBParseTreeRewriter new.
	number := aNumber.
	parser := aParseTree copy.
	rewriter
		replace: self expressionToReplace
		withValueFrom: [ :oNode | 
			| oldNode newNode |
			nNode := RBParser parseRewriteExpression: self newExpression.
			nNode := nNode copyInContext: rewriter context.
			oldNode := oNode.
			newNode := nNode.
			newNode ]
		when: [ :node | 
			number := number - 1.
			number = 0 ].
	rewriter executeTree: parser.
	parser := rewriter tree.
	^ parser formattedCode
]

{ #category : #private }
MutantOperator >> mutationFor: aCompiledMethod with: aParseTree number: aNumberOfSelector [

	^ MethodMutation
		  for: aCompiledMethod
		  using: self
		  nodeNumber: aNumberOfSelector
		  ofClass: aCompiledMethod methodClass
]

{ #category : #'mutant generation' }
MutantOperator >> mutationsFor: aCompiledMethod [ 

	(aCompiledMethod ignoredMutationOperators includes: self class) ifTrue: [ ^ Array new ].

	^self mutationsFor: aCompiledMethod with: aCompiledMethod parseTree.
	
]

{ #category : #'mutant generation' }
MutantOperator >> mutationsFor: aCompiledMethod with: aParseTree [ 
	| numberOfMutations |
	numberOfMutations := ((aCompiledMethod hasPragmaNamed: #ignoreForMutations) or: [ aCompiledMethod hasPragmaNamed: #ignoreForCoverage ])
		ifTrue: [ ^ Array new ]
		ifFalse: [ self timesToApplyIn: aCompiledMethod with: aParseTree ].
	^ (1 to: numberOfMutations)
		collect: [:aNumberOfSelector | self
				mutationFor: aCompiledMethod
				with: aParseTree
				number: aNumberOfSelector]
]

{ #category : #applying }
MutantOperator >> newExpression [
	self subclassResponsibility
]

{ #category : #suggestions }
MutantOperator >> suggestionFor: aMutation using: aMutantKillingSuggestionGenerator [
	^'No Suggestion'
]

{ #category : #applying }
MutantOperator >> timesToApplyIn: aCompiledMethod [ 
	^self timesToApplyIn: aCompiledMethod  with: aCompiledMethod parseTree.
	
]

{ #category : #applying }
MutantOperator >> timesToApplyIn: aCompiledMethod with: aParseTree [ 
	"Evaluates how many times can the operator be applyied"	
	|searcher timesToApply|
	searcher := RBParseTreeSearcher new.
	timesToApply := 0.
	searcher matches:self expressionToReplace do:[:node :answer | timesToApply := timesToApply + 1].
	searcher executeTree: aParseTree copy.
	^timesToApply.
	
]
