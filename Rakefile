require 'webruby'

# This file sets up the build environment for a webruby project.
Webruby::App.setup do |conf|
  # Entrypoint file name
  conf.entrypoint = 'app/app.rb'

  # By default, the build output directory is "build/"
  conf.build_dir = 'build'

  # Use 'release' for O2 mode build, and everything else for O0 mode.
  # Or you can also use '-O0', '-O1', '-O2', '-O3', etc. directly
  conf.compile_mode = 'debug'

  # Note that different functions are needed for the 3 different loading methods,
  # for example, WEBRUBY.run_source requires all the parsing code is present,
  # while the first 2 modes only requires code for loading bytecodes.
  # Given these considerations, we allow 3 loading modes in webruby:
  #
  # 0 - only WEBRUBY.run is supported
  # 1 - WEBRUBY.run and WEBRUBY.run_bytecode are supported
  # 2 - all 3 loading methods are supported
  #
  # It may appear that mode 0 and mode 1 requires the same set of functions
  # since they both load bytecodes, but due to the fact that mode 0 only loads
  # pre-defined bytecode array, chances are optimizers may perform some tricks
  # to eliminate parts of the source code for mode 0. Hence we still distinguish
  # mode 0 from mode 1 here
  conf.loading_mode = 2

  # 2 Ruby source processors are available right now:
  #
  # :mrubymix - The old one supporting static require
  # :gen_require - The new one supporting require
  conf.source_processor = :gen_require

  # By default the final output file name is "webruby.js"
  conf.output_name = 'webruby.js'

  # You can append a JS file at the end of the final output file
  # For example, a runner file like following can be used to run
  # Ruby code automatically:
  #
  # (function () {
  #    var w = new WEBRUBY();
  #    w.run();
  # }) ();
  #
  # NOTE: We used to support a js_bin target which will compile
  # a `main.c` file to run the code, but now we favor this method
  # instead of the old one.
  # conf.append_file = 'runner.js'

  # We found that if memory init file is used, browsers will hang
  # for a long time without response. As a result, we disable memory
  # init file by default. However, you can test this yourself
  # and re-enable it by commenting/removing the next line.
  conf.ldflags << "--memory-init-file 0"

  # The syntax for adding gems here are kept the same as mruby.
  # Below are a few examples:

  # mruby-eval gem, all parsing code will be packed into the final JS!
  conf.gem :core => "mruby-eval"
  conf.gem :github => "ksss/mruby-method"

  # JavaScript calling interface
  conf.gem :git => 'git://github.com/xxuejie/mruby-js.git', :branch => 'master'
  conf.gem :github => 'ksss/mruby-ostruct'

  # OpenGL ES 2.0 binding
  # conf.gem :git => 'git://github.com/xxuejie/mruby-gles.git', :branch => 'master'

  # Normally we wouldn't use this example gem, I just put it here to show how to
  # add a gem on the local file system, you can either use absolute path or relative
  # path from mruby root, which is modules/webruby.
  # conf.gem "#{root}/examples/mrbgems/c_and_ruby_extension_example"
end
