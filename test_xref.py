"""Tests for bin/xref"""

import os
import shutil
import tempfile
import unittest

import importlib.util
import importlib.machinery
_loader = importlib.machinery.SourceFileLoader(
    "xref", os.path.join(os.path.dirname(__file__) or ".", "bin", "xref")
)
_spec = importlib.util.spec_from_loader("xref", _loader)
xref = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(xref)

TESTDATA = os.path.join(os.path.dirname(__file__), "testdata", "n", "xref")


class TestFiles(unittest.TestCase):
    def test_finds_md_and_txt(self):
        got = xref.files(TESTDATA)
        names = [os.path.basename(f) for f in got]
        self.assertIn("alpha.md", names)
        self.assertIn("202603111158-short-source.txt", names)

    def test_sorted(self):
        got = xref.files(TESTDATA)
        self.assertEqual(got, sorted(got))


class TestLinks(unittest.TestCase):
    def test_finds_links(self):
        got = xref.links(TESTDATA)
        alpha = [v for k, v in got if k.endswith("alpha.md")][0]
        self.assertIn("bravo", alpha)
        self.assertIn("charlie", alpha)

    def test_excludes_references_line(self):
        got = xref.links(TESTDATA)
        # no file should report links that came from a References: line
        for _, links in got:
            for l in links:
                self.assertNotIn("References", l)

    def test_dedup(self):
        got = xref.links(TESTDATA)
        alpha = [v for k, v in got if k.endswith("alpha.md")][0]
        self.assertEqual(alpha.count("charlie"), 1)


class TestRevlinks(unittest.TestCase):
    def test_basic(self):
        got = xref.revlinks(TESTDATA)
        charlie = got.get("charlie", [])
        bases = [os.path.basename(f) for f in charlie]
        self.assertIn("alpha.md", bases)
        self.assertIn("bravo.md", bases)
        self.assertIn("delta.md", bases)

    def testkeysindependent(self):
        got = xref.revlinks(TESTDATA)
        self.assertEqual(
            [os.path.basename(f) for f in got["202603111200"]],
            ["202603111158-short-source.txt"],
        )
        self.assertEqual(
            [os.path.basename(f) for f in got["202603111200-target-note"]],
            ["202603111201-source-note.md"],
        )


class TestRewrite(unittest.TestCase):
    def testoutsidefrontmatter(self):
        cases = (
            '',
            'References: literal body text\n',
            'Ordinary body.\n\n---\nReferences: literal body text\n',
            'Ordinary body.\n\n---\nReferences: literal body text\n---\n',
            '---\nTitle: Note\n---\nReferences: literal body text\n',
            '---\nTitle: Note\n---\n\n---\nReferences: literal body text\n',
            '---\nReferences: old\n',
            '---\nReferences: old',
        )
        for text in cases:
            for refs in ('', '[[source]]'):
                with self.subTest(text=text, refs=refs):
                    self.assertEqual(xref.rewrite(text, refs), text)

    def testonlyfrontmatter(self):
        text = ('---\nReferences: old\n---\n'
                '\n---\nReferences: literal body text\n---\n')
        want = ('---\nReferences: [[source]]\n---\n'
                '\n---\nReferences: literal body text\n---\n')
        self.assertEqual(xref.rewrite(text, '[[source]]'), want)


class TestXref(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        shutil.copytree(TESTDATA, os.path.join(self.tmp, "notes"))
        self.root = os.path.join(self.tmp, "notes")

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def test_charlie_refs(self):
        xref.run(self.root)
        with open(os.path.join(self.root, "charlie.md"), encoding='utf-8') as f:
            text = f.read()
        self.assertIn("[[alpha]]", text)
        self.assertIn("[[bravo]]", text)
        self.assertIn("[[delta]]", text)

    def test_missing_warning(self):
        warnings = xref.run(self.root)
        self.assertTrue(any("missing" in w for w in warnings))

    def test_target_note(self):
        xref.run(self.root)
        with open(os.path.join(self.root, "202603111200-target-note.md"), encoding='utf-8') as f:
            text = f.read()
        self.assertIn("[[202603111158-short-source]]", text)
        self.assertIn("[[202603111201-source-note]]", text)

    def test_subdir_src(self):
        xref.run(self.root)
        with open(os.path.join(self.root, "alpha.md"), encoding='utf-8') as f:
            text = f.read()
        self.assertIn("[[subdir-src]]", text)

    def test_dot_in_filename(self):
        xref.run(self.root)
        with open(os.path.join(self.root, "v1.2-release.md"), encoding='utf-8') as f:
            text = f.read()
        self.assertIn("[[dot-source]]", text)

    def test_sub_target(self):
        xref.run(self.root)
        with open(os.path.join(self.root, "sub/target.md"), encoding='utf-8') as f:
            text = f.read()
        self.assertIn("[[full-path-src]]", text)
        self.assertIn("[[short-name-src]]", text)

    def test_golf_foxtrot_refs(self):
        xref.run(self.root)
        with open(os.path.join(self.root, "golf.md"), encoding='utf-8') as f:
            text = f.read()
        self.assertIn("[[foxtrot]]", text)

    def test_no_spurious_refs(self):
        xref.run(self.root)
        with open(os.path.join(self.root, "echo.md"), encoding='utf-8') as f:
            text = f.read()
        self.assertIn("References:\n", text)  # empty refs

    def test_all_files_after_xref(self):
        warnings = xref.run(self.root)
        self.assertEqual(
            [w for w in warnings if "missing" in w],
            ["file not found: following [[missing]] from [[echo]]"],
        )
        expect = {
            "202603111200-target-note.md": "---\nReferences: [[202603111158-short-source]] [[202603111201-source-note]]\n---\nTarget note for backlink regression coverage.",
            "alpha.md": "---\nReferences: [[subdir-src]]\n---\nAlpha links to [[bravo]], [[charlie]], and [[charlie]].",
            "bravo.md": "---\nReferences: [[alpha]]\n---\nBravo links to [[charlie]].",
            "charlie.md": "---\nReferences: [[alpha]] [[bravo]] [[delta]]\n---\nCharlie does not link onward.",
            "echo.md": "---\nReferences:\n---\nEcho links to [[missing]].",
            "golf.md": "---\nReferences: [[foxtrot]]\n---\nGolf is a nested-path target.",
            "hotel.md": "---\nReferences: [[foxtrot]]\n---\nHotel is another normalized target.",
            "Z/R/n/subdir-src.md": "---\nReferences:\n---\nSubdir source links to [[alpha]].",
            "202603111300-apple.md": "---\nReferences: [[202603111299-ambig-src]]\n---\nApple target.",
            "202603111300-apricot.md": "---\nReferences: [[202603111298-apricot-src]]\n---\nApricot target.",
            "v1.2-release.md": "---\nReferences: [[dot-source]]\n---\nNote with dot in name.",
            "v1-2-release.md": "---\nReferences:\n---\nWrong file that should not match v1.2-release.",
            "202603111158-short-source.txt": "---\nReferences:\n---\nShort source links to [[202603111200]].",
            "202603111201-source-note.md": "---\nReferences:\n---\nSource note links to [[202603111200-target-note]].",
            "202603111298-apricot-src.md": "---\nReferences:\n---\nApricot source links to [[202603111300-apricot]].",
            "202603111299-ambig-src.md": "---\nReferences:\n---\nAmbiguous source links to [[202603111300]] and [[202603111300-apple]].",
            "delta.md": "---\nReferences:\n---\nDelta links to [[charlie]].",
            "dot-source.md": "---\nReferences:\n---\nSource links to [[v1.2-release]].",
            "foxtrot.md": "---\nReferences:\n---\nFoxtrot links to [[Z/R/n/golf]], [[Z/R/hotel]], and [[golf]].",
            "sub/target.md": "---\nReferences: [[full-path-src]] [[short-name-src]]\n---\nTarget in a subdirectory.",
            "full-path-src.md": "---\nReferences:\n---\nFull path source links to [[sub/target]].",
            "short-name-src.md": "---\nReferences:\n---\nShort name source links to [[target]].",
        }
        for name, want in expect.items():
            path = os.path.join(self.root, name)
            with open(path, encoding='utf-8') as f:
                # first 4 lines
                got = "\n".join(f.read().splitlines()[:4])
            self.assertEqual(got, want, f"mismatch in {name}")


class TestRegressions(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = tmp.name

    def note(self, name, body):
        path = os.path.join(self.root, name)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(f'---\nReferences:\n---\n{body}')
        return path

    def testshortkey(self):
        apricot = self.note('123-apricot.md', 'Apricot.\n')
        apple = self.note('123-apple.md', 'Apple.\n')
        self.note('a.md', '[[123]]\n')
        self.note('b.md', '[[123-apricot]]\n')

        self.assertEqual(xref.run(self.root), [])
        with open(apple, encoding='utf-8') as f:
            self.assertEqual(f.read(), '---\nReferences: [[a]]\n---\nApple.\n')
        with open(apricot, encoding='utf-8') as f:
            self.assertEqual(f.read(), '---\nReferences: [[b]]\n---\nApricot.\n')

    def testcasealiases(self):
        target = self.note('target.md', 'Target.\n')
        self.note('a.md', '[[target]] [[Z/R/n/target]]\n')
        self.note('b.md', '[[TARGET]] [[Z/R/TARGET]]\n')

        self.assertEqual(xref.run(self.root), [])
        want = '---\nReferences: [[a]] [[b]]\n---\nTarget.\n'
        with open(target, encoding='utf-8') as f:
            self.assertEqual(f.read(), want)
        self.assertEqual(xref.run(self.root), [])
        with open(target, encoding='utf-8') as f:
            self.assertEqual(f.read(), want)

    def testlastlink(self):
        for ext in ('md', 'txt'):
            with self.subTest(ext=ext):
                key = f'target-{ext}'
                target = self.note(f'{key}.{ext}', 'Target.\n')
                source = self.note('source.md', f'[[{key}]]\n')
                self.assertEqual(xref.run(self.root), [])
                with open(target, encoding='utf-8') as f:
                    self.assertEqual(f.read(),
                                     '---\nReferences: [[source]]\n---\nTarget.\n')

                with open(source, 'w', encoding='utf-8') as f:
                    f.write('No links remain.\n')
                self.assertEqual(xref.run(self.root), [])
                with open(target, encoding='utf-8') as f:
                    self.assertEqual(f.read(), '---\nReferences:\n---\nTarget.\n')
                with open(source, encoding='utf-8') as f:
                    self.assertEqual(f.read(), 'No links remain.\n')
                os.unlink(target)

    def testunrelatedfiles(self):
        cases = {
            'crlf.md': b'---\r\nReferences:\r\n---\r\nBody.\r\n',
            'invalid.txt': b'---\nReferences:\n---\nBody: \xff\xfe\n',
            'body.md': b'Ordinary body.\n\n---\nReferences: literal body text\n',
        }
        stamp = 1600000000000000000
        for name, text in cases.items():
            path = os.path.join(self.root, name)
            with open(path, 'wb') as f:
                f.write(text)
            os.utime(path, ns=(stamp, stamp))

        self.assertEqual(xref.run(self.root), [])
        for name, text in cases.items():
            with self.subTest(name=name):
                path = os.path.join(self.root, name)
                with open(path, 'rb') as f:
                    self.assertEqual(f.read(), text)
                self.assertEqual(os.stat(path).st_mtime_ns, stamp)

    def testpreservebytes(self):
        target = os.path.join(self.root, 'target.md')
        head = b'---\r\nTitle: \xff\r\n'
        body = b'---\nBody: \xfe\r\n\n---\r\nReferences: literal body text\nEnd.'
        for eol in (b'\n', b'\r\n', b'\r'):
            with self.subTest(eol=eol):
                source = self.note('source.md', '[[target]]\n')
                with open(target, 'wb') as f:
                    f.write(head + b'References: old' + eol + body)
                self.assertEqual(xref.run(self.root), [])
                want = head + b'References: [[source]]' + eol + body
                with open(target, 'rb') as f:
                    self.assertEqual(f.read(), want)

                with open(source, 'w', encoding='utf-8') as f:
                    f.write('No links remain.\n')
                self.assertEqual(xref.run(self.root), [])
                want = head + b'References:' + eol + body
                with open(target, 'rb') as f:
                    self.assertEqual(f.read(), want)

    def testsecondrun(self):
        target = self.note('target.md', 'Target.\n')
        source = self.note('source.md', '[[target]]\n')
        self.assertEqual(xref.run(self.root), [])
        with open(target, 'rb') as f:
            want = f.read()
        stamp = 1600000000000000000
        for path in (source, target):
            os.utime(path, ns=(stamp, stamp))

        self.assertEqual(xref.run(self.root), [])
        with open(target, 'rb') as f:
            self.assertEqual(f.read(), want)
        for path in (source, target):
            self.assertEqual(os.stat(path).st_mtime_ns, stamp)


if __name__ == "__main__":
    unittest.main()
