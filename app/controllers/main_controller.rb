class MainController < ApplicationController
    protect_from_forgery with: :null_session

    def register
        if !params[:username].nil? && !params[:username].empty? && !params[:password].nil? && !params[:password].empty?
            if params[:password] == params[:password_confirmation]
                u = User.create(username: params[:username], password: params[:password])
                if u.new_record?
                    render json: {error: "invalid"}
                else
                    render json: {success: "success"}
                end
            else
                render json: {error: "confirmation"}
            end
        else
            render json: {error: "emptyparams"}
        end
    end

    def login
        if !params[:username].nil? && !params[:username].empty? && !params[:password].nil? && !params[:password].empty?
            user = User.find_by_username(params[:username])
            if user && user.authenticate(params[:password])
                token = Token.create(user: user)
                if token.new_record?
                    render json: {error: "invalid"}
                else
                    render json: {token: token.content}
                end
            else
                render json: {error: "autherror"}
            end
        else
            render json: {error: "emptyparams"}
        end
    end

    def logout
        if params[:token].nil? || params[:token].empty?
            render json: {error: "unauthorized"}
        else
            token = Token.find_by_content(params[:token])
            if token
                token.destroy
                render json: {success: "success"}
            else
                render json: {error: "unauthorized"}
            end
        end
    end

    def endpoint
        if params[:token].nil? || params[:token].empty?
            render status: 403, text: "Forbidden"
        else
            token = Token.find_by_content(params[:token])
            if token
                response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
                render json: response
            else
                render status: 403, text: "Forbidden"
            end
        end
    end
end