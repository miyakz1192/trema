#
# run command of Trema shell.
#
# Author: Yasuhito Takamiya <yasuhito@gmail.com>
#
# Copyright (C) 2008-2012 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


require "trema/dsl"


module Trema
  module Shell
    def run controller
      sanity_check

      if controller
        if /ELF/=~ `file #{ controller }`
          stanza = DSL::Run.new
          stanza.path controller
          App.new stanza
        else
          require "trema"
          ARGV.replace controller.split
          $LOAD_PATH << File.dirname( controller )
          Trema.module_eval IO.read( controller )
        end
      end

      runner = DSL::Runner.new( $config )
      runner.maybe_run_switch_manager
      $config.switches.each do | name, switch |
        if switch.running?
          switch.restart!
        else
          switch.run!
        end
      end

      $config.apps.values.last.daemonize!
      $context.dump

      true
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
