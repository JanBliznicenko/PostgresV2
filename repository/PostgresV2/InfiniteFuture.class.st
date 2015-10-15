Class {
	#name : #InfiniteFuture,
	#superclass : #DateAndTime,
	#category : #PostgresV2
}

{ #category : #'instance creation' }
InfiniteFuture class >> new [
	^ self julianDayNumber: SmallInteger maxVal
]
