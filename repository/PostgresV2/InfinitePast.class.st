Class {
	#name : #InfinitePast,
	#superclass : #DateAndTime,
	#category : #PostgresV2
}

{ #category : #'instance creation' }
InfinitePast class >> new [
	^ self julianDayNumber: SmallInteger maxVal negated
]
