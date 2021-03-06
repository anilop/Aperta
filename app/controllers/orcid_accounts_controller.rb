# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class OrcidAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :disabled_response, unless: -> { TahiEnv.orcid_connect_enabled? }
  respond_to :json

  def show
    render json: orcid_account
  end

  def clear
    requires_user_can(:remove_orcid, Journal)
    orcid_account.reset!
    render json: orcid_account
  end

  private

  def orcid_account
    @orcid_account ||= OrcidAccount.find(params[:id])
  end

  def disabled_response
    render(
      status: 404,
      json: {
        message: 'Orcid integration is not currently enabled.'
      },
      serializer: ErrorSerializer
    )
  end
end
