# Commons Configuration

The Commons Configuration software library provides a generic configuration interface which enables a Dart/Flutter application to read configuration data from a variety of sources.

Note that this project is still in its early stages and so may not yet provide complete/full functionality. We will be building up functionality over the next few months through numerous small iterative releases.

## Table of Contents
- [Commons Configuration](#commons-configuration)
  - [Table of Contents](#table-of-contents)
  - [About The Project](#about-the-project)
    - [Features](#features)
  - [Getting Started](#getting-started)
    - [Installation](#installation)
    - [Import Package](#import-package)
  - [Usage](#usage)
    - [Import Package](#import-package)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [License](#license)
  - [Contact](#contact)
  - [Acknowledgments](#acknowledgments)
  - [Limitation of Liability](#limitation-of-liability)

## About The Project

The Commons Configuration software library provides a generic configuration interface which enables a Dart/Flutter application to read configuration data from a variety of sources. Commons Configuration provides typed access to single, and multi-valued configuration parameters as demonstrated by the following code:

```Dart
double d = config.getDouble("number");
int i = config.getInt("number");
```

### Features
To do: list the features

## Getting Started

Add the package as a dependency.

### Installation
Add the package to your dependencies.

```
pub add commons_config
```

### Import Package

Import the library in your code.

```Dart
import 'package:commons_config/commons_config.dart';
```

## Usage
See the [User Guide](docs/user-guide.md) for detailed information.

## Roadmap

See the [open issues](https://github.com/Limeslice-Software-Foundation/commons-config/issues) for a full list of proposed features (and known issues).

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Limeslice Software Foundation [https://limeslice.org](https://limeslice.org)


## Acknowledgments

We would like to thank the authors of the Apache Commons Configuration package which provided the basis for this package. 

## Limitation of Liability

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.