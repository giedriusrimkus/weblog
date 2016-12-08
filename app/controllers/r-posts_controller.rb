class PostsController < ApplicationController

# before_action :authenticate_user!, except: [:index, :show]
before_filter :authorize_admin, except: [:index, :show]
before_action :set_post_attachment, only: [:show, :edit, :update, :destroy]

def index
	@post = Post.all.order('created_at DESC')
end

def show
	@post = Post.friendly.find(params[:id])
	@post_attachments = @post.post_attachments.all
end

def new
	@post = Post.new
	@post_attachment = @post.post_attachments.build
end

def create
	@post = Post.new(post_params)
	respond_to do |format|
		if @post.save
			params[:post_attachments]['post_image'].each do |a|
				@post_attachment = @post.post_attachments.create!(:post_image => a, :post_id => @post.id)
			end
			format.html { redirect_to @post, notice: 'Post was successfully created.' }
		else
			format.html { render action: 'new' }
		end
	end
end

def edit
	@post = Post.friendly.find(params[:id])
end

def update
	@post = Post.friendly.find(params[:id])
	if @post.update(post_params)
		flash[:success] = "Post updated"
		redirect_to @post
	else
		flash[:danger] = "Error updating post!"
		render :edit
	end
end


def destroy
	@post = Post.friendly.find(params[:id])
	@post.destroy
	flash[:success] = "Post deleted"
	redirect_to posts_path
end

def publish
	@post = Post.friendly.find(params[:id])
	@post.published = true
	if @post.save
		redirect_to @post
		flash[:success] = "Post published"
	else
		flash[:alert] = "Error occured"
		redirect_to @post
	end
end

def unpublish
	@post = Post.friendly.find(params[:id])
	@post.published = false
	if @post.save
		redirect_to @post
		flash[:success] = "Post unpublished"
	else
		flash[:alert] = "Error occured"
		redirect_to @post
	end
end

private

def post_params
	params.require(:post).permit(:title, :body, :published,  post_attachments_attributes: [:id, :post_id, :post_image])
end

end