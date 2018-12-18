Class {
	#name : #BaselineOfPostgresV2,
	#superclass : #BaselineOf,
	#category : #BaselineOfPostgresV2
}

{ #category : #baselines }
BaselineOfPostgresV2 >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
			spec package: #PostgresV2 with: [ spec requires: #('NeoJSON') ] ].
	spec group: 'default' with: #(#PostgresV2)
]
