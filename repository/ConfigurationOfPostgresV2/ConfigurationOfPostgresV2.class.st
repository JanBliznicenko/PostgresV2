"
I am ConfigurationOfPostgresV2, the Metacello configuration of the PostgreSQL database driver.

PostgresV2 implements version 2 of the PG wire protocol over TCP.
"
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

{ #category : #catalog }
ConfigurationOfPostgresV2 class >> catalogContactInfo [

	^'Maintained by the community, please send an email to the Pharo Development List <pharo-dev@lists.pharo.org>'
]

{ #category : #catalog }
ConfigurationOfPostgresV2 class >> catalogDescription [

	  ^'PostgresV2 provides the required classes to connect and perform queries on PostgreSQL database servers using itstext-based protocol.'
]

{ #category : #catalog }
ConfigurationOfPostgresV2 class >> catalogKeywords [

	^#('database' 'connectivity' 'postgres' 'sql')
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

{ #category : #baselines }
ConfigurationOfPostgresV2 >> baseline24: spec [ 
	<version: '2.4-baseline'>
 
	spec for: #pharo do: [ 
		spec project: 'JSON' with: [ 
			spec 
				className: #ConfigurationOfJSON;
				repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
				versionString: #stable.
		 ].
	
		spec package: #PostgresV2 with: [ spec requires: #('JSON') ].
	].
       
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

{ #category : #baselines }
ConfigurationOfPostgresV2 >> baseline25: spec [ 
	<version: '2.5-baseline'>
 
	spec for: #pharo do: [ 
		spec project: 'NeoJSON' with: [ 
			spec 
				className: #ConfigurationOfNeoJSON;
				repository: 'http://mc.stfx.eu/Neo/';
				versionString: #stable.
		 ].
	
		spec package: #PostgresV2 with: [ spec requires: #('NeoJSON') ].
	].
       
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

{ #category : #baselines }
ConfigurationOfPostgresV2 >> baseline26: spec [ 
	<version: '2.6-baseline'>
 
	spec for: #pharo do: [ 
		spec project: 'NeoJSON' with: [ 
			spec 
				className: #ConfigurationOfNeoJSON;
				repository: 'http://mc.stfx.eu/Neo/';
				versionString: #stable.
		 ].
	
		spec package: #PostgresV2 with: [ spec requires: #('NeoJSON') ].
	].
       
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

{ #category : #'symbolic versions' }
ConfigurationOfPostgresV2 >> development: spec [ 
	<symbolicVersion: #development>
	
	spec for: #'pharo3.0.x' version: '2.4'.
	spec for: #'pharo4.0.x' version: '2.6-baseline'.	
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

{ #category : #'symbolic versions' }
ConfigurationOfPostgresV2 >> stable: spec [ 
	<symbolicVersion: #stable>
	
	spec for: #'pharo3.0.x' version: '2.3'.
	spec for: #'pharo4.0.x' version: '2.6'.
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
		spec package: 'PostgresV2' with: 'PostgresV2-GuillermoPolito.31'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version23: spec [
	<version: '2.3' imports: #('2.0-baseline')>
	
	spec for: #common do: [
		spec blessing: #release.
		spec package: 'PostgresV2' with: 'PostgresV2-EstebanMaringolo.32'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version24: spec [
	<version: '2.4' imports: #('2.4-baseline')>
	
	spec for: #common do: [
		spec description: 'Adds support to JSON native datatype available from PostgreSQL 9.2'.
		spec author: 'EstebanMaringolo'.
		spec blessing: #development.
		spec package: 'PostgresV2' with: 'PostgresV2-EstebanMaringolo.33'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version25: spec [
	<version: '2.5' imports: #('2.5-baseline')>
	
	spec for: #common do: [
		spec description: 'Changes dependendency from PharoExtras/JSON to NeoJSON for JSON native datatype'.
		spec author: 'EstebanMaringolo'.
		spec blessing: #stable.
		spec package: 'PostgresV2' with: 'PostgresV2-EstebanMaringolo.34'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]

{ #category : #versions }
ConfigurationOfPostgresV2 >> version26: spec [
	<version: '2.6' imports: #('2.6-baseline')>
	
	spec for: #common do: [
		spec description: 'Changes dependendency from PharoExtras/JSON to NeoJSON for JSON native datatype'.
		spec author: 'EstebanMaringolo'.
		spec blessing: #stable.
		spec package: 'PostgresV2' with: 'PostgresV2-EstebanMaringolo.47'.
	].

	spec for:  #squeak do: [
		spec package: 'Cryptography' with: 'Cryptography-mtf.36'.	
	]
]
