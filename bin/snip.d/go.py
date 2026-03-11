"""Go snippet expansions."""


def _expand_gobasic(builder, _args):
    """Go basic program structure."""
    builder.write("package main")
    builder.write("")
    builder.write("import (")
    builder.indent()
    builder.write('"fmt"')
    builder.dedent()
    builder.write(")")
    builder.write("")
    builder.write("func main() {")
    builder.indent()
    builder.write('fmt.Println("Hello, world")')
    builder.dedent()
    builder.write("}")


def _expand_goerr(builder, _args):
    """Go error handling pattern."""
    builder.write("import (")
    builder.indent()
    builder.write('"errors"')
    builder.write('"fmt"')
    builder.write('"log"')
    builder.write('"os"')
    builder.dedent()
    builder.write(")")
    builder.write("")
    builder.write("// processFile demonstrates proper error handling with wrapping.")
    builder.write("func processFile(filename string) error {")
    builder.indent()
    builder.write("f, err := os.Open(filename)")
    builder.write("if err != nil {")
    builder.indent()
    builder.write('return fmt.Errorf("open file: %w", err)')
    builder.dedent()
    builder.write("}")
    builder.write("defer f.Close()")
    builder.write("")
    builder.write("data, err := processData(f)")
    builder.write("if err != nil {")
    builder.indent()
    builder.write('return fmt.Errorf("process data: %w", err)')
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("if len(data) == 0 {")
    builder.indent()
    builder.write('return errors.New("empty data")')
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("return nil")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("func main() {")
    builder.indent()
    builder.write("if err := processFile(filename); err != nil {")
    builder.indent()
    builder.write("log.Fatal(err)")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")


def _expand_gostruct(builder, args):
    """Go struct. [Name field1 type1...] - Define struct with fields and constructor."""
    # Parse arguments
    struct_name = "User"  # Default struct name
    fields = [
        ("ID", "int"),
        ("Name", "string"),
        ("Email", "string"),
        ("Created", "time.Time"),
    ]  # Default fields

    if args:
        # First argument is struct name
        struct_name = args[0]

        # Remaining arguments are field/type pairs
        if len(args) > 1:
            # Clear default fields if any custom fields provided
            fields = []

            # Process pairs of field name and type
            for i in range(1, len(args), 2):
                if i + 1 < len(args):
                    field_name = args[i]
                    field_type = args[i + 1]
                    fields.append((field_name, field_type))

    # Write struct definition
    builder.write(f"// {struct_name} represents a {struct_name.lower()}")
    builder.write(f"type {struct_name} struct {{")
    builder.indent()

    # Add fields
    for field_name, field_type in fields:
        builder.write(f"{field_name} {field_type}")

    builder.dedent()
    builder.write("}")
    builder.write("")

    # Constructor
    builder.write(f"// New{struct_name} creates a new {struct_name}")

    # Determine constructor parameters based on fields
    # Skip ID field (common pattern for generated fields)
    constructor_fields = [(name, typ) for name, typ in fields if name != "ID"]

    param_list = ", ".join(
        [f"{name.lower()} {typ}" for name, typ in constructor_fields]
    )

    builder.write(f"func New{struct_name}({param_list}) *{struct_name} {{")
    builder.indent()
    builder.write(f"return &{struct_name}{{")
    builder.indent()

    # Add field initializers
    for field_name, field_type in fields:
        if field_name == "ID":
            # Skip ID for constructor
            continue
        if field_name == "Created" and field_type == "time.Time":
            builder.write(f"{field_name}: time.Now(),")
        else:
            # Use parameter with same name but lowercase
            builder.write(f"{field_name}: {field_name.lower()},")

    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")


def _expand_gocli(builder, _args):
    """Go command-line flags."""
    builder.write("package main")
    builder.write("")
    builder.write("import (")
    builder.indent()
    builder.write('"flag"')
    builder.write('"fmt"')
    builder.write('"log"')
    builder.write('"os"')
    builder.dedent()
    builder.write(")")
    builder.write("")
    builder.write("// Config holds command-line configuration.")
    builder.write("type Config struct {")
    builder.indent()
    builder.write("Verbose bool")
    builder.write("Output  string")
    builder.write("Count   int")
    builder.write("Files   []string")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("func parseFlags() (*Config, error) {")
    builder.indent()
    builder.write("var cfg Config")
    builder.write("")
    builder.write('flag.BoolVar(&cfg.Verbose, "v", false, "verbose output")')
    builder.write('flag.StringVar(&cfg.Output, "o", "output.txt", "output file")')
    builder.write('flag.IntVar(&cfg.Count, "n", 1, "number of iterations")')
    builder.write("flag.Parse()")
    builder.write("")
    builder.write("cfg.Files = flag.Args()")
    builder.write("if len(cfg.Files) == 0 {")
    builder.indent()
    builder.write('return nil, fmt.Errorf("no input files specified")')
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("return &cfg, nil")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("func run(cfg *Config) error {")
    builder.indent()
    builder.write("if cfg.Verbose {")
    builder.indent()
    builder.write('log.Printf("processing %d files with %d iterations", len(cfg.Files), cfg.Count)')
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("for _, file := range cfg.Files {")
    builder.indent()
    builder.write("if err := processFile(file, cfg); err != nil {")
    builder.indent()
    builder.write('return fmt.Errorf("process file %s: %w", file, err)')
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("return nil")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("func processFile(filename string, cfg *Config) error {")
    builder.indent()
    builder.write("// TODO: implement file processing")
    builder.write("if cfg.Verbose {")
    builder.indent()
    builder.write('log.Printf("processing %s", filename)')
    builder.dedent()
    builder.write("}")
    builder.write("return nil")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("func main() {")
    builder.indent()
    builder.write("cfg, err := parseFlags()")
    builder.write("if err != nil {")
    builder.indent()
    builder.write('fmt.Fprintf(os.Stderr, "error: %v\\n", err)')
    builder.write("flag.Usage()")
    builder.write("os.Exit(1)")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("if err := run(cfg); err != nil {")
    builder.indent()
    builder.write("log.Fatal(err)")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")


def _expand_gomod(builder, args):
    """Go module initialization."""
    module_name = args[0] if args else "example.com/myproject"

    builder.write("// go.mod file")
    builder.write(f"module {module_name}")
    builder.write("")
    builder.write("go 1.21")
    builder.write("")
    builder.write("require (")
    builder.indent()
    builder.write("// Add dependencies here")
    builder.dedent()
    builder.write(")")
    builder.write("")
    builder.write("// Initialize with:")
    builder.write(f"// go mod init {module_name}")
    builder.write("// go mod tidy")


def _expand_gotest(builder, args):
    """Go test. [Func RetType ParamTypes...] - Create test function with tests and benchmarks."""
    # Default values
    func_name = "Add"
    return_type = "int"
    param_types = ["int", "int"]

    if args:
        # First argument is function name
        func_name = args[0]

        # Second argument is return type
        if len(args) > 1:
            return_type = args[1]

        # Remaining arguments are parameter types
        if len(args) > 2:
            param_types = args[2:]

    # Create parameter string
    param_list = []
    for i, ptype in enumerate(param_types):
        param_list.append(f"{chr(97+i)} {ptype}")
    param_str = ", ".join(param_list)

    builder.write("package mypackage")
    builder.write("")
    builder.write("import (")
    builder.indent()
    builder.write('"fmt"')
    builder.write('"testing"')
    builder.dedent()
    builder.write(")")
    builder.write("")
    builder.write(f"func {func_name}({param_str}) {return_type} {{")
    builder.indent()
    if return_type == "error":
        builder.write("return nil")
    elif return_type == "string":
        builder.write('return ""')
    elif return_type == "bool":
        builder.write("return true")
    elif "int" in return_type:
        builder.write("return 0")
    elif "float" in return_type:
        builder.write("return 0.0")
    else:
        builder.write("// TODO: implement function")
        builder.write("return nil")
    builder.dedent()
    builder.write("}")
    builder.write("")

    # Helper function for test setup (optional)
    builder.write("// testSetup prepares test resources")
    builder.write("func testSetup() func() {")
    builder.indent()
    builder.write("// Initialize test resources")
    builder.write("")
    builder.write("// Return teardown function")
    builder.write("return func() {")
    builder.indent()
    builder.write("// Clean up test resources")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")
    builder.write("")

    # Test function with table-driven tests
    builder.write(f"func Test{func_name}(t *testing.T) {{")
    builder.indent()
    builder.write("// Setup test environment and defer cleanup")
    builder.write("teardown := testSetup()")
    builder.write("defer teardown()")
    builder.write("")

    builder.write("// Table-driven test cases")
    builder.write("tests := []struct {")
    builder.indent()
    builder.write("name     string")

    # Parameter fields
    for i, ptype in enumerate(param_types):
        builder.write(f"{chr(97+i)}        {ptype}")

    builder.write(f"expected {return_type}")
    builder.dedent()
    builder.write("}{")
    builder.indent()

    # Example test cases based on return type
    if return_type == "int":
        builder.write('{name: "simple", a: 1, b: 2, expected: 3},')
        builder.write('{name: "negative", a: -1, b: 1, expected: 0},')
    elif return_type == "string":
        builder.write(
            '{name: "simple", a: "hello", b: "world", expected: "helloworld"},'
        )
    elif return_type == "bool":
        builder.write('{name: "true case", a: true, b: true, expected: true},')
        builder.write('{name: "false case", a: true, b: false, expected: false},')
    else:
        builder.write(
            '{name: "case1", /* TODO: add test parameters */, expected: /* expected value */},'
        )

    builder.dedent()
    builder.write("}")
    builder.write("")

    builder.write("// Run subtests for each test case")
    builder.write("for _, tc := range tests {")
    builder.indent()
    builder.write("t.Run(tc.name, func(t *testing.T) {")
    builder.indent()
    builder.write(
        f"got := {func_name}(tc.{', tc.'.join([chr(97+i) for i in range(len(param_types))])})"
    )

    # Conditional check based on return type
    builder.write("if got != tc.expected {")
    builder.indent()

    # Format string for error message depends on return type
    format_str = ""
    if return_type == "string":
        format_str = "%q"
    elif return_type == "bool":
        format_str = "%v"
    elif "int" in return_type:
        format_str = "%d"
    elif "float" in return_type:
        format_str = "%f"
    else:
        format_str = "%v"

    # Build error message with appropriate formatting
    params_fmt = ", ".join(
        [f"tc.{chr(97+i)}" for i in range(len(param_types))]
    )
    verbs = ", ".join(["%v"] * len(param_types))
    errfmt = (
        f'{func_name}({verbs}) = {format_str};'
        f' expected {format_str}'
    )
    builder.write(
        f't.Errorf("{errfmt}", {params_fmt}, got, tc.expected)'
    )
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("})")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")
    builder.write("")

    # Add test example
    builder.write(f"func Example{func_name}() {{")
    builder.indent()

    # Create example parameters based on type
    example_params = []
    for i, ptype in enumerate(param_types):
        if ptype == "string":
            example_params.append(f'"{chr(97+i)}"')
        elif ptype == "bool":
            example_params.append("true")
        elif "int" in ptype:
            example_params.append(str(i + 1))
        elif "float" in ptype:
            example_params.append(f"{i+1}.0")
        else:
            example_params.append("nil // TODO: provide appropriate value")

    builder.write(f"result := {func_name}({', '.join(example_params)})")
    builder.write("fmt.Println(result)")
    builder.write("// Output:")

    # Generate expected output based on return type
    if return_type == "string":
        builder.write('// ""')
    elif return_type == "bool":
        builder.write("// true")
    elif "int" in return_type:
        builder.write("// 0")
    elif "float" in return_type:
        builder.write("// 0")
    else:
        builder.write("// <expected output>")

    builder.dedent()
    builder.write("}")
    builder.write("")

    # Add benchmark function
    builder.write(f"func Benchmark{func_name}(b *testing.B) {{")
    builder.indent()

    # Create benchmark parameters
    bench_params = []
    for i, ptype in enumerate(param_types):
        if ptype == "string":
            bench_params.append(f'"benchmark{i}"')
        elif ptype == "bool":
            bench_params.append("true")
        elif "int" in ptype:
            bench_params.append(str(i + 10))
        elif "float" in ptype:
            bench_params.append(f"{i+10}.5")
        else:
            bench_params.append("nil // TODO: provide appropriate value")

    # Reset timer in case setup is expensive
    builder.write("// Perform any expensive setup here")
    builder.write("b.ResetTimer()")

    # Benchmark loop
    builder.write("for i := 0; i < b.N; i++ {")
    builder.indent()
    builder.write(f"{func_name}({', '.join(bench_params)})")
    builder.dedent()
    builder.write("}")

    # Optionally add parallel benchmark
    builder.write("")
    builder.write("// Example of parallel benchmark")
    builder.write('b.Run("Parallel", func(b *testing.B) {')
    builder.indent()
    builder.write("b.ResetTimer()")
    builder.write("b.RunParallel(func(pb *testing.PB) {")
    builder.indent()
    builder.write("for pb.Next() {")
    builder.indent()
    builder.write(f"{func_name}({', '.join(bench_params)})")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("})")
    builder.dedent()
    builder.write("})")

    builder.dedent()
    builder.write("}")


def _expand_goswitch(builder, args):
    """Go switch. [var case1 case2...] - Create switch statement with cases."""
    # Parse arguments
    variable = "value"  # Default variable name
    cases = ["case1", "case2", "default"]  # Default cases

    if args:
        # First argument is the variable name
        variable = args[0]

        # Remaining arguments are cases
        if len(args) > 1:
            cases = args[1:]

    # Write switch statement
    builder.write(f"switch {variable} {{")
    builder.indent()

    # Add cases
    for case in cases:
        if case.lower() == "default":
            builder.write("default:")
        else:
            builder.write(f"case {case}:")

        builder.indent()
        if case.lower() == "default":
            builder.write("// Handle default case")
        else:
            builder.write(f"// Handle {case} case")
        builder.dedent()

    builder.dedent()
    builder.write("}")


def _expand_gointf(builder, args):
    """Go interface. [Name method1 method2...] - Define interface with empty methods."""
    # Default interface name and methods
    interface_name = "Reader"
    methods = ["Read"] if not args or len(args) <= 1 else args[1:]

    if args:
        # First argument is interface name
        interface_name = args[0]

    # Write interface definition
    builder.write(
        f"// {interface_name} defines methods for {interface_name.lower()} operations"
    )
    builder.write(f"type {interface_name} interface {{")
    builder.indent()

    # Add methods with empty signatures
    for method in methods:
        builder.write(f"{method}()")

    builder.dedent()
    builder.write("}")

    # Add implementation example for all interfaces
    struct_name = f"My{interface_name}"

    builder.write("")
    builder.write(f"// {struct_name} implements the {interface_name} interface")
    builder.write(f"type {struct_name} struct {{")
    builder.indent()
    builder.write("// implementation fields")
    builder.dedent()
    builder.write("}")
    builder.write("")

    # Implement all methods
    for method in methods:
        builder.write(f"// {method} implements {interface_name}.{method}")
        builder.write(f"func (m *{struct_name}) {method}() {{")
        builder.indent()
        builder.write("// implementation")
        builder.dedent()
        builder.write("}")
        builder.write("")


SNIPPETS = {
    "gobasic": _expand_gobasic,
    "gocli": _expand_gocli,
    "goerr": _expand_goerr,
    "gointf": _expand_gointf,
    "gomod": _expand_gomod,
    "gostruct": _expand_gostruct,
    "goswitch": _expand_goswitch,
    "gotest": _expand_gotest,
}
