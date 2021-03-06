import test from 'ava';
import Core from '../../../lib/core';

test('dirname/1', (t) => {
  let result = Core.filename.dirname('/usr/src/kalle.erl');
  t.is(result, '/usr/src');

  result = Core.filename.dirname('usr/kalle.erl');
  t.is(result, 'usr');

  result = Core.filename.dirname('kalle.erl');
  t.is(result, '.');

  result = Core.filename.dirname('/kalle.erl');
  t.is(result, '/');
});

test('join/1', (t) => {
  let result = Core.filename.join(['/usr', 'local', 'bin']);
  t.is(result, '/usr/local/bin');

  result = Core.filename.join(['a', '///b/', 'c/']);
  t.is(result, '/b/c');

  result = Core.filename.join(['a/b///c/']);
  t.is(result, 'a/b/c');
});

test('join/2', (t) => {
  const result = Core.filename.join('/usr', 'bin');
  t.is(result, '/usr/bin');
});
