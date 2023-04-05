# Persistence Library


The `Persistence` library provides a set of classes built on top of `CoreData` to ensure easy use of `CoreData` in projects.

## Installation
This library can be installed using Swift Package Manager (SPM). You can add it to your project by adding the following line to your `Package.swift` file:

```swift
.package(url: "git@github.com:Paletech/iOS-Persistence.git", from: "1.0.0")
```

## Usage

To use this library, you must first initialize a `CDStorage` object with the name of the Core Data model that you want to use. For example, to initialize a `CDStorage` object with a model named "ParentViewModel" and store type `.sqlite`, you can use the following code:

```swift
let coreDataStorage = CDStorage(modelName: "ParentViewModel", bundle: PersistenceResources.bundle, storeType: .sqlite)
```

Once you have initialized a `CDStorage` object, you can use it to initialize a `PersistenceStore` object for a specific `NSManagedObject` subclass. For example, to initialize a `UserPersistenceStore` object for a `User` entity, you can use the following code:

```swift
let store = UserPersistenceStore(coreDataStorage.persistentContainer, contextType: .view)
```
## Managed Protocol
To use the convenience methods provided by this library, your `NSManagedObject` subclasses must conform to the `Managed` protocol. This protocol provides a number of static methods and properties that simplify common Core Data tasks, such as fetching and counting entities.

Here is an example of a `NSManagedObject` subclass that conforms to the Managed protocol:

```swift
class User: NSManagedObject, Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \User.lastName, ascending: true)]
    }
}
```
## Inserting Objects
To insert a new object into Core Data, you can use the `insertObject()` method provided by the `NSManagedObjectContext` extension:
```swift
let user = context.insertObject() as User
```
## Fetching Objects
To fetch objects from Core Data, you can use the `fetch()` method provided by the `Managed` protocol:
```swift
let users = User.fetch(in: context)
```
You can also specify sort descriptors and a configuration block to further refine the fetch request:
```swift
let sortDescriptors = [NSSortDescriptor(keyPath: \User.lastName, ascending: true)]
let predicate = NSPredicate(format: "firstName == %@", argumentArray: ["John"])

let users = User.fetch(in: context, with: sortDescriptors) { request in
    request.predicate = predicate
}
```
