# Commons Configuration User Guide

## About

This document describes the features of the Commons Configuration library; starting with the very basics and up to the more advanced topics. If you read it in a linear way, you should get a sound understanding of the provided classes and the possibilities they offer. But you can also skip sections and jump directly to the topics you are most interested in.

## Table of Contents

- [Commons Configuration User Guide](#commons-configuration-user-guide)
  - [About](#about)
  - [Table of Contents](#table-of-contents)
  - [Using Configuration](#using-configuration)
  - [Basic Features](#basic-features)
  - [Properties Files](#properties-files)
  

## Using Configuration

Commons Configuration allows you to access configuration properties from a variety of different sources. No matter if they are stored in a properties file, a XML document, or a JSON document, they can all be accessed in the same way through the generic Configuration interface.

Another strength of Commons Configuration is its ability to mix configurations from heterogeneous sources and treat them like a single logic configuration. This section will introduce you to the different configurations available and will show you how to combine them.

### Configuration Sources

Currently there are quite a number of different sources of Configuration objects. But, by just using a Configuration interface versus a specific type like XMLConfiguration or PropertiesConfiguration, you are sheltered from the mechanics of actually retrieving the configuration values. These various sources include:

- PropertiesConfiguration Loads configuration values from a properties file.
- XMLConfiguration Takes values from an XML document.
- INIConfiguration Loads the values from a .ini file as used by Windows.
- MapConfiguration An in-memory configuration backed by a Map instance.

### The Configuration interface

All the classes in this package that represent different kinds of configuration sources share a single interface: Configuration. This interface allows you to access and manipulate configuration properties in a generic way.

A major part of the methods defined in the Configuration interface deals with retrieving properties of different data types. All these methods take a key as an argument that points to the desired property. This is a string value whose exact meaning depends on the concrete Configuration implementation used. They try to find the property specified by the passed in key and convert it to their target type; this converted value will be returned. All of these methods allow you to specify a default value, which will be returned if the property cannot be found. The following data types are supported:

- BigInt
- bool
- DateTime
- double
- int
- String
- Uri
- List

## Basic Features

The Configuration interface defines a whole bunch of methods. This abstract class serves as a common base class for most of the Configuration implementations in Commons Configuration and provides a great deal of the functionality required by the interface.

### Handling of missing properties

The default behaviour if a property value cannot be found is to return the given default value. In the event that no default value is provided, and exception will be thrown if the <code>throwExceptionOnMissing</code> field is set to true. In this case a <code>NoSuchElementException</code> will be thrown. If <code>throwExceptionOnMissing</code> is set to false, a sensible default will be returned for example <code>getDouble</code> will return 0.0, <code>getInt</code> will return 0 and <code>getBool</code> will return false, etc.

<code>getList</code> is special in that it will not throw a <code>NoSuchElementException</code>, instead it will return an empty list.

To enable or disable the throwing of exceptions on missing properties you can call the following setter method: <code>set throwExceptionOnMissing(bool throwExceptionOnMissing)</code> on the Configuration instance.

### List Handling

With <code>getList()</code>, the Configuration interface defines methods for dealing with properties that have multiple values. When a configuration source is processed the corresponding Configuration implementation detects such properties with multiple values and ensures that the data is correctly stored.

When modifying properties the <code>addProperty()</code> and <code>setProperty()</code> methods of Configuration also implement special list handling. The property value that is passed to these methods can be a list resulting in a property with multiple values. If the property value is a string, it is checked whether it contains the list delimiter character. If this is the case, the string is split, and its single parts are added one by one. The list delimiter character is the comma by default. It is also taken into account when the configuration source is loaded (i.e. string values of properties will be checked whether they contain this delimiter). You can set the list delimiter character using the following setter method: <code>set listDelimiter(String listDelimiter)</code>. Is is also possible to disable splitting of String properties by calling the following setter method with a parameter value of true: <code>set delimiterParsingDisabled(bool delimiterParsingDisabled)</code>.

### Variable Interpolation

If you are familiar with the Dart language then you have likely seen String interpolation: <code>print('The list size is ${list.length}')</code>. Commons Configuration supports this feature as well, here is an example, we use a properties file in this example, but other configuration sources work the same way.

```
application.name = Killer App
application.version = 1.6.2

application.title = ${application.name} ${application.version}
```

If you now retrieve the value for the <code>application.title</code> property, the result will be Killer App 1.6.2. So per default variables are interpreted as the keys of other properties. This is only a special case, the general syntax of a variable name is <code>${prefix:name}</code>. The prefix tells Commons Configuration that the variable is to be evaluated in a certain context. We have already seen that the context is the current configuration instance if the prefix is missing. The following other prefix names are supported by default:

| Prefix      | Description |
| ----------- | ----------- |
| env         | Prefix of the lookup object for resolving environment properties. See <code>Platform.environment[key]</code>. |
| cfg         | Prefix of the lookup object for resolving configuration environment properties. See <code>String.fromEnvironment(key)</code>. |

### Customizing interpolation

This sub section goes a bit behind the scenes of interpolation and explains some approaches how you can add your own interpolation facilities. Under the hood interpolation is implemented using the <code>StrSubstitutor</code> class of the [Commons Lang](https://pub.dev/packages/commons_lang) package. This class uses objects derived from the <code>StrLookup</code> class for resolving variables. StrLookup defines a simple <code>lookup()</code> method that must be implemented by custom implementations; it expects the name of a variable as argument and returns the corresponding value (further details can be found in the documentation of Commons Lang). The standard prefixes for variables we have covered so far are indeed realized by special classes derived from StrLookup.

It is now possible to create your own implementation of <code>StrLookup</code> and make it available for all configuration objects under a custom prefix. We will show how this can be achieved. The first step is to create a new class derived from <code>StrLookup</code>, which must implement the <code>lookup()</code> method. As an example we implement a rather dull lookup object that simply returns a kind of "echo" for the variable passed in:

```Dart
class EchoLookup extends StrLookup {
    String lookup(String varName) {
        return "Value of variable " + varName;
    }
}
```
Now we want this class to be called for variables with the prefix echo. For this purpose the EchoLookup class has to be registered at the <code>ConfigurationInterpolator</code> class with the desired prefix. ConfigurationInterpolator implements a thin wrapper over the StrLookup API defined by Commons Lang. It has a <code>registerLookup()</code> method, which we have to call as follows:

```Dart
Configuration config = ...
EchoLookup echoLookup = EchoLookup();
config.getInterpolator.registerLookup('echo', echoLookup);
```

## Properties Files

Properties files are a popular means of configuring applications and Commons Configuration supports this format. This section introduces the features of the <code>PropertiesConfiguration</code> class. Note that PropertiesConfiguration is a very typical example for an implementation of the Configuration interface and many of the features described in this section (e.g. list handling or interpolation) are supported by other configuration classes as well. This is because most configuration implementations that ship with Commons Configuration are derived from the common base <code>Configuration</code> class , which implements these features.

### Using PropertiesConfiguration

Let's start with a simple properties file named usergui.properties with the following content:

```
# Properties definining the GUI
colors.background = #FFFFFF
colors.foreground = #000080

window.width = 500
window.height = 300
```

To load this file, you'll write:

```Dart
FileConfiguration config = new PropertiesConfiguration(File('usergui.properties'));
config.load();
```

After the properties file was loaded you can access its content through the methods of the Configuration interface, e.g.

```Dart
String backColor = config.getString('colors.background');
int width = config.getInt('window.width')
```

### Includes

If a property is named "include" and the value of that property is the name of a file on the disk, that file will be included into the configuration. Here is an example:

```
# usergui.properties

include = colors.properties
include = sizes.properties
```

colors.properties file as follows:

```
# colors.properties

colors.background = #FFFFFF
```

### Lists

As was already pointed out in the section List handling of Basic features, Commons Configuration has the ability to return easily a list of values. For example a properties file can contain a list of comma separated values:

```
# chart colors
colors.pie = #FF0000, #00FF00, #0000FF
```

You don't have to split the value manually, you can retrieve List directly with:

```Dart
List colorList = config.getList("colors.pie");
```

Alternatively, you can specify a list of values in your properties file by using the same key on several lines:

```
# chart colors
colors.pie = #FF0000;
colors.pie = #00FF00;
colors.pie = #0000FF;
```

### Saving

To save your configuration, just call the save() method:

```Dart
PropertiesConfiguration config = new PropertiesConfiguration(File('usergui.properties'));
config.setProperty("colors.background", "#000000");
config.save();
```

You can also save a copy of the configuration to another file:

```Dart
PropertiesConfiguration config = new PropertiesConfiguration('usergui.properties');
config.setProperty("colors.background", "#000000");
config.saveToFileSync(File('usergui.backup.properties'));
```

More information about saving properties files (and file-based configurations in general) can be found in the section about File-based Configurations.

### Special Characters and Escaping

If you need a special character in a property like a line feed, a tabulation or an unicode character, you can specify it with the same escaped notation used for Dart Strings. The list separator ("," by default), can also be escaped:

```
key = This \n string \t contains \, escaped \\ characters 
```

When dealing with lists of elements that contain backslash characters (e.g. file paths on Windows systems) escaping rules can become pretty complex. The first thing to keep in mind is that in order to get a single backslash, you have to write two:

```
config.dir = C:\\Temp\\
```

This issue is not specific to Commons Configuration, but is related to the standard format for properties files. Now if you want to define a list with file paths, you may be tempted to write the following:

```
# Wrong way to define a list of directories
config.dirs = C:\\Temp\\,D:\\data\\
```

s the comment indicates, this will not work. The trailing backslash of the first directory is interpreted as escape character for the list delimiter. So instead of a list with two elements only a single value of the property is defined - clearly not what was desired. To get a correct list the trailing backslash has to be escaped. This is achieved by duplicating it (yes, in a properties file that means that we now need 4 backslashes):

```
# Correct way to define a list of directories
config.dirs = C:\\Temp\\\\,D:\\data\\
```

So a sequence of 4 backslashes in the value of a property is interpreted as an escaped backslash and eventually results in a single backslash. This creates another problem when a properties file should refer to the names of network shares. Typically these names start with two backslashes, so the obvious way to define such a property is as follows:

```
# Wrong way to define a list of network shares
config.dirs = \\\\share1,\\\\share2
```

Unfortunately, this will not work because the shares contain the reserved sequence of 4 backslashes. So when reading the value of the config.dirs property a list with two elements is returned starting only with a single backslash. To fix the problem the sequence for escaping a backslash has to be duplicated - we are now at 8 backslashes:

```
# Correct way to define a list of network shares
config.dirs = \\\\\\\\share1,\\\\\\\\share2
```

As becomes obvious, escape sequences can become pretty complex and unreadable. In such situations it is recommended to use the alternative way of defining a list: just use the same key multiple times. In this case no additional escaping of backslashes (beyond the usual duplicating required by properties files) is needed because there is no list delimiter character involved. Using this syntax the list of network shares looks like the following:

```
# Straightforward way to define a list of network shares
config.dirs = \\\\share1
config.dirs = \\\\share2
```

## File-based Configurations

Often configuration properties are stored in files on the user's hard disk, e.g. in .properties files or as XML documents. Configuration classes that deal with such properties need to provide typical operations like loading or saving files. The files to be processed can be specified in several different flavors like <code>File</code> objects or relative or absolute path names.

To provide a consistent way of dealing with configuration files in Commons Configuration the <code>FileConfiguration</code> interface exists. FileConfiguration defines a standard API for accessing files and is implemented by many configuration implementations, including PropertiesConfiguration.

In the following sections we take a closer look at the methods of the FileConfiguration interface and how they are used.

### Specifying the file

When creating a file configuration you can pass in an optional <code>File</code> instance as a parameter in the constructor.

You also have access to the <code>file</code> property and can set that.

### Loading

File configuration provides a <code>load</code> method that will load the configuration from the file. If a file has not been set then a <code>ConfigurationException</code> is thrown.

The <code>load</code> method calls the <code>loadFromFileSync</code> abstract method. All subclasses must implement this method.

#### Abstract load methods

File configuration defines two abstract methods that must be implemented by subclasses, one for synchronous reading of a file and one for asynchronous reading of a file:

```Dart
void loadFromFileSync(File file);
Future<void> loadFromFile(File file);
```

### Saving

File configuration provides a <code>save</code> method that will write configuration properties to the file. If a file has not been set then a <code>ConfigurationException</code> is thrown.

The <code>save</code> method call the <code>saveToFileSync</code> abstract method. All subclasses must implement this method.

#### Abstract save methods

File configuration defines two abstract methods that must be implemented by subclasses, one for synchronous saving of a file and one for asynchronous saving of a file:

```Dart
void saveToFileSync(File file);
Future<void> saveToFile(File file);
```

#### Example loading and saving

```Dart
PropertiesConfiguration config = PropertiesConfiguration(File('gui.properties'));
config.load();
config.setProperty('colors.background','#000000');
config.save();
```

### Automatic Saving

If you want to ensure that every modification of a configuration object is immediately written to disk, you can enable the automatic saving mode. This is done through the <code>autoSave</code> property. The dafult value for <code>autoSave</code> is <code>false</code>.

```Dart
PropertiesConfiguration config = PropertiesConfiguration(File('gui.properties'));
config.autoSave = true;
config.setProperty("colors.background", "#000000"); // the configuration is saved after this call
```

 Be careful with this property set to true when you have many updates on your configuration, this may lead to many I/O operations. 