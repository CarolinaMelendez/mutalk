Class {
	#name : #MethodInstaller,
	#superclass : #Object,
	#category : #'MuTalk-Model'
}

{ #category : #installing }
MethodInstaller >> install: aMethod for: selector in: aClass withProtocol: methodProtocol [

	aClass
		addAndClassifySelector: selector
		withMethod: aMethod
		inProtocol: methodProtocol
]

{ #category : #installing }
MethodInstaller >> installFromSource: aSourceCode in: aClass [
	"Install a SourceCode in aClass. Raise exception in case de installation is
	not posible."

	[ aClass compile: aSourceCode ]
		on: Error , SyntaxErrorNotification
		do: [ :error | MethodInstallerException signal ]
]

{ #category : #installing }
MethodInstaller >> installFromSourceSilently: aSourceCode in: aClass [
	"Install a SourceCode in aClass. Raise exception in case de installation is
	not posible."

	[ aClass compileSilently: aSourceCode ]
		on: Error , SyntaxErrorNotification
		do: [ :error | MethodInstallerException signal ]
]

{ #category : #installing }
MethodInstaller >> uninstall: aSelector from: aClass [ 
	"Uninstall a method referenced by aSelector in aClass. Raise exception in
	case de uninstall is	not posible."
	[aClass removeSelector: aSelector]
		on: Error
		do: [:error | MethodInstallerException signal]
]
