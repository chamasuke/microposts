class User < ApplicationRecord
    before_save { self.email.downcase! }
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
    has_secure_password
    
    has_many :microposts
    
     #自分がフォローしているユーザーへの参照
    has_many :relationships
    has_many :followings, through: :relationships, source: :follow
    
     #自分をフォローしているユーザーへの参照
    has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
    has_many :followers, through: :reverses_of_relationship, source: :user
    
     #自分がお気に入り登録している投稿への参照
    has_many :favorites, dependent: :destroy
    has_many :likes, through: :favorites, source: :micropost
    
    def follow(other_user)
      unless self == other_user #自分自身をフォローしてないかを確認
        self.relationships.find_or_create_by(follow_id: other_user.id)
      end
    end

    def unfollow(other_user)
      relationship = self.relationships.find_by(follow_id: other_user.id)
      relationship.destroy if relationship
    end

    def following?(other_user)
      self.followings.include?(other_user)
    end
    
    def feed_microposts
      Micropost.where(user_id: self.following_ids + [self.id])
    end
    
    #お気に入り登録
    def favorite(favo_post)
      #すでにお気に入り登録しているか調べる。
      unless self.likes.include?(favo_post)
        self.favorites.find_or_create_by(micropost_id: favo_post.id)
      end
    end
    
    #お気に入りから削除
    def unfavorite(favo_post)
      favo = self.favorites.find_by(micropost_id: favo_post.id)
      favo.destroy if favorites
    end
    
    #お気に入り登録済みかを確認
    def favorite?(favo_post)
      self.likes.include?(favo_post)
    end
end
