Class {
	#name : #ConfigurationOfPostgresV2,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfPostgresV2
}

{ #category : #private }
ConfigurationOfPostgresV2 class >> bootstrapPackage: aString from: aPath [ 
	| repository version |
	repository := MCHttpRepository
				location: aPath
				user: ''
				password: ''.
	repository
		versionReaderForFileNamed: aString , '.mcz'
		do: [:reader | 
			version := reader version.
			version load.
			version workingCopy repositoryGroup addRepository: repository]
]

{ #category : #private }
ConfigurationOfPostgresV2 class >> ensureMetacello [
	"Bootstrap Gofer (if necessary), load latest mcz file for ConfigurationOfMetacello (using old 
	 Gofer API), then load the latest version of Metacello itself."

	Smalltalk at: #MetacelloProject ifAbsent: [ | error |
		"list of repositories to try, in case primary repository is not accessible"
		(Array 
			with: 'http://www.squeaksource.com/MetacelloRepository' 
			with: 'http://seaside.gemstone.com/ss/metacello') do: [:repositoryUrl |
				([
					Smalltalk at: #Gofer ifAbsent: [
					"Current version of Gofer from which to bootstrap - as of 1.0-beta.21"
						self bootstrapPackage: 'Gofer-Core-lr.115' from: repositoryUrl ].
					Smalltalk at: #Gofer ifPresent: [:goferClass | | gofer |
						gofer := goferClass new
							url: repositoryUrl;
							yourself.
						[ gofer addPackage: 'ConfigurationOfMetacello' ] on: Warning do: [:ex | ex resume ].
						gofer load ]]
							on: Error
							do: [ :ex |
								error := ex.
								Transcript 
									cr; 
									show: 'failed ensureMetacello: ';
									show: ex description printString;
									show: '...retrying'.
								"try again"
								ex return: nil ]) ~~ nil
					ifTrue: [
						"load 'default' group of Metacello"
						(Smalltalk at: #ConfigurationOfMetacello) perform: #load.
						^self ]].
		"shouldn't get here unless the load failed ... throw an error"
		self error: 'retry with alternate repository failed: ', error description printString ]
]

{ #category : #'metacello tool support' }
ConfigurationOfPostgresV2 class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #'metacello tool support' }
ConfigurationOfPostgresV2 class >> lastMetacelloVersionLoad [
	"Answer the last version loaded and the list of packages loaded for that version."

	LastVersionLoad == nil ifTrue: [ LastVersionLoad := nil -> 'default' ].
	^LastVersionLoad
]

{ #category : #loading }
ConfigurationOfPostgresV2 class >> load [
	"self load"

	^self project latestVersion load
]

{ #category : #'metacello tool support' }
ConfigurationOfPostgresV2 class >> metacelloVersion: versionString loads: anArrayOrString [
	"Stash the last version loaded and the list of packages loaded for that version. The list
	 of packages will be used by the tools when doing 'Load Package Version'"

	LastVersionLoad := versionString -> anArrayOrString
]

{ #category : #accessing }
ConfigurationOfPostgresV2 class >> project [

	^self new project
]

{ #category : #baselines }
ConfigurationOfPostgresV2 >> baseline10: spec [ 
	<version: '1.0-baseline'>
        
	spec for: #squeakCommon do: [
		spec 
			blessing: #baseline;
               	description: '1.0 baseline for PostgresV2';
			repository: 'http://www.squeaksource.com/PostgresV2'.
		spec package: 'PostgresV2'.
		].
	
	spec for: #squeak do: [
		spec package: 'Cryptography' with: 
				[ spec repository: 'http://www.squeaksource.com/Cryptography' ]
		]
]

{ #category : #baselines }
ConfigurationOfPostgresV2 >> baseline20: spec [ 
	<version: '2.0-baseline'>
        
	spec for: #squeakCommon do: [
		spec 
			blessing: #baseline;
               	description: '2.0 baseline for PostgresV2 in the new SmalltalkHub repository';
			repository: 'http://smalltalkhub.com/mc/PharoExtras/PostgresV2/main'.
		spec package: 'PostgresV2'.
		].
	
	spec for: #squeak do: [
		spec package: 'Cryptography' with: 
				[ spec repository: 'http://www.squeaksource.com/Cryptography' ]
		]
]

{ #category : #accessing }
ConfigurationOfPostgresV2 >> project [

	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		self class ensureMetacello.
		"Construct Metacello project"
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self.
		project := constructor project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version10: spec [
	<version: '1.0' imports: #('1.0-baseline')>
	
	spec for: #common do: [
		spec blessing: #release.
		spec package: 'PostgresV2' with: 'PostgresV2-YanniChiu.25'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version11: spec [
	<version: '1.1' imports: #('1.0-baseline')>
	
	spec for: #common do: [
		spec blessing: #release.
		spec package: 'PostgresV2' with: 'PostgresV2-SvenVanCaekenberghe.28'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version21: spec [
	<version: '2.1' imports: #('2.0-baseline')>
	
	spec for: #common do: [
		spec blessing: #release.
		spec package: 'PostgresV2' with: 'PostgresV2-SvenVanCaekenberghe.28'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version22: spec [
	<version: '2.2' imports: #('2.0-baseline')>
	
	spec for: #common do: [
		spec blessing: #release.
		spec package: 'PostgresV2' with: 'PostgresV2-SvenVanCaekenberghe.28'.
	].

	spec for: #'pharo3.x' do: [ 
		spec package: 'PostgresV2' with: 'PostgresV2-EstebanMaringolo.32'.	
	 ].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]
