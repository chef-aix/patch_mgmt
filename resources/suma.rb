#
# Copyright 2016, International Business Machines Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include AIX::PatchMgmt

##############################
# PROPERTIES
##############################
property :desc, String, name_property: true
property :oslevel, String
property :location, String
property :targets, String
property :preview_only, [true, false], default: false

default_action :download

##############################
# load_current_value
##############################
load_current_value do
end

##############################
# ACTION: download
##############################
action :download do
  # check ohai nim info
  check_nim_info(node)

  # obtain suma parameters
  params = suma_params(node, desc, oslevel, location, targets)
  return if params.nil?

  # suma preview
  suma = Suma.new(params)
  suma.preview
  return if preview_only == true
  return unless suma.downloaded?

  # suma download
  converge_by("download #{suma.downloaded} fixes to '#{params['DLTarget']}'") do
    suma.download
  end
  return if suma.failed? || LppSource.exist?(params['LppSource'], node)

  # create nim lpp source
  nim = Nim.new
  converge_by("define nim lpp source \'#{params['LppSource']}\'") do
    nim.define_lpp_source(params['LppSource'], params['DLTarget'])
  end
end
