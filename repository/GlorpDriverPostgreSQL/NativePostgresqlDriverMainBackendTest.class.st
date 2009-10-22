Class {
	#name : #NativePostgresqlDriverMainBackendTest,
	#superclass : #GlorpMainBackendTest,
	#category : #GlorpDriverPostgreSQL
}

{ #category : #'as yet unclassified' }
NativePostgresqlDriverMainBackendTest class >> glorpBackendFacility [
	| facility login |
	facility := GlorpBackendFacility new.
	login := Login new
		database: PostgreSQLPlatform new;
		username: 'sodbxtest';
		password: 'sodbxtest';
		connectString: '127.0.0.1_sodbxtest'.
	facility login: login.
	^ facility
]

{ #category : #'as yet unclassified' }
NativePostgresqlDriverMainBackendTest >> testSetToBaseTestAFacility [
	super testSetToBaseTestAFacility.
	SqueakDatabaseAccessor DefaultDriver: NativePostgresDriver.
	GlorpDatabaseLoginResource current: nil.
	GlorpDatabaseLoginResource defaultLogin: self class glorpBackendFacility login
]
