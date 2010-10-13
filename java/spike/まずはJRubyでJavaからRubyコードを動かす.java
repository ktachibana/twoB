package twob;

import static java.util.Arrays.*;
import static org.junit.Assert.*;

import java.io.*;

import org.jruby.embed.*;
import org.junit.*;

public class まずはJRubyでJavaからRubyコードを動かす {
	private ScriptingContainer container;
	private StringWriter rubyout;

	@Before
	public void setupContainer() {
		container = new ScriptingContainer();
		container.setCurrentDirectory("./twoB");
		container.setRunRubyInProcess(true);
	}

	/** "foo"と出力してみる */
	@Test
	public void fooを出力() throws Exception {
		rubyout = new StringWriter();
		container.setOutput(rubyout);
		container.runScriptlet("print 'foo'");
		assertEquals(rubyout.toString(), "foo");
	}

	@Test
	public void setLoadPathsの実験() throws Exception {
		container.setLoadPaths(asList("/home/tachibana/devel/twoB/lib"));
		container.runScriptlet("$stderr.puts $LOAD_PATH");
		container.runScriptlet("require 'yaml_marshaler'");
	}

	@Ignore
	public void TwoBを走らせてみる() throws Exception {
		container.setLoadPaths(asList("src", "lib", "view/src",
				"/var/lib/gems/1.8/gems/rspec-1.3.0/lib"));
		container.runScriptlet("load '/var/lib/gems/1.8/gems/rspec-1.3.0/lib/spec/autorun.rb'");
	}

}
