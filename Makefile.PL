use inc::Module::Install;

name            ('Plucene-Analysis-CJKAnalyzer');
abstract        ('CJK text analyzer for Plucene');
author          ('Yung-chung Lin <xern@cpan.org>');
version_from    ('lib/Plucene/Analysis/CJKAnalyzer.pm');
license         ('perl');


requires  ('Plucene');

build_requires  ('Test::More');

auto_install();

&WriteAll;