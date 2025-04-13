# Lucid
A desktop widget kit for Flutter.

## Widget API Design Philosophy
### Use-Cases
When designing a widget's API, Lucid ensures that the following use-cases
are optimized:

 * I want to use a single widget, on its own, with complete direct styling.
 * I want to use a few widgets that share inherited styles, but without full app theming.
 * I want to use Lucid everywhere, with app-level theming.

### Light Mode and Dark Mode
All visual widgets should support light mode and dark mode styles.
