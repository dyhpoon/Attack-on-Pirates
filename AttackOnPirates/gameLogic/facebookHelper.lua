module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'
local storyboard = require( "storyboard" )
local json = require "json"
local facebook = require "facebook"
local appId = "" -- your app id
local facebookQuery

function query(query)
	local group = display.newGroup()

	local myScore = {}
	local friendsScore = {}
	local changedToNextScene = false

	print("at facebookHelper")
	facebookQuery = query
	print("query: " .. query)

	local function listener( event )

	    if ( "session" == event.type ) then
	        print(event.phase) -- login, loginCancelled
	        if facebookQuery == "UPDATE_SCORE_AND_CHECK_FRIENDS_SCORE" then
	        	local storyLevel = localStorage.get("storyLevel")
	        	local attachment = {
	        			score = storyLevel
	        	}
	        	facebook.request("me/scores", "POST", attachment)

	        elseif facebookQuery == "CHECK_MY_SCORE" or facebookQuery == "CHECK_FRIENDS_SCORE" then
	        	facebook.request("me/scores")

	        elseif facebookQuery == "CHECK_FRIENDS_SCORE_FINAL" then
	        	facebook.request(appId .. "/scores")

	        elseif facebookQuery == "UPDATE_USER_SCORE" then
	        	local storyLevel = localStorage.get("storyLevel")
	        	local attachment = {
	        			score = storyLevel
	        	}
	        	facebook.request("me/scores", "POST", attachment)

	        elseif facebookQuery == "CHECK_MY_SCORE_BUT_NO_RECORD" or "CHECK_MY_SCORE_BUT_NO_RECORD_AND_CHECK_FRIENDS_SCORE_LATER" then
	        	facebook.request("me/scores", "POST", {score = 0})

	        elseif facebookQuery == "POST_A_PICTURE" then

	        else
	        	-- do nothing

	        end

	    -- request
	    elseif ( "request" == event.type ) then
	        local response = event.response
	        --print("response"..response)
	        if ( not event.isError ) then

	        	-- response type is boolean (probably request is a POST/DELETE method)
	        	if response == "true" then

	        		if facebookQuery == "CHECK_MY_SCORE_BUT_NO_RECORD" then
		            	print("facebookQuery: CHECK_MY_SCORE_BUT_NO_RECORD")
		            	facebookQuery = "CHECK_MY_SCORE"
		            	facebook.login( appId, listener, {"publish_actions"} )

	        		elseif facebookQuery == "CHECK_MY_SCORE_BUT_NO_RECORD_AND_CHECK_FRIENDS_SCORE_LATER" then
		            	print("facebookQuery: CHECK_MY_SCORE_BUT_NO_RECORD_AND_CHECK_FRIENDS_SCORE_LATER")
		            	facebookQuery = "CHECK_FRIENDS_SCORE"
		            	facebook.login( appId, listener, {"publish_actions"} )

		            elseif facebookQuery == "UPDATE_SCORE_AND_CHECK_FRIENDS_SCORE" then
		            	print("facebookQuery: UPDATE_SCORE_AND_CHECK_FRIENDS_SCORE")
		            	facebookQuery = "CHECK_FRIENDS_SCORE"
		            	facebook.login( appId, listener, {"publish_actions"} )
	            	end

	            elseif response == "false" then
	            	return

	            -- response type is an error
	        	elseif (json.decode(event.response)).data == nil then
	        		print(response)

	        	-- response type is requested information
	            elseif facebookQuery == "CHECK_MY_SCORE" or facebookQuery == "CHECK_FRIENDS_SCORE" then
	            	print("facebookQuery: CHECK_MY_SCORE")
	            	response = json.decode( event.response )
	            	local data = response.data
	            	
	            	print("check if nil")
		            if #data == 0 then
		            	print("please do not crash")
		            	if facebookQuery == "CHECK_MY_SCORE" then
		            		facebookQuery = "CHECK_MY_SCORE_BUT_NO_RECORD"
		            	elseif facebookQuery == "CHECK_FRIENDS_SCORE" then
		            		facebookQuery = "CHECK_MY_SCORE_BUT_NO_RECORD_AND_CHECK_FRIENDS_SCORE_LATER"
		            	end
		            	print("redirect to: " .. facebookQuery)
		            	facebook.login(appId, listener, {"publish_actions"} )
		            else
		            	local name = data[1].user.name
		            	local id = data[1].user.id
		            	local score = data[1].score

		            	table.insert(myScore, {name, id, score})
		            	if facebookQuery == "CHECK_FRIENDS_SCORE" then
		            		facebookQuery = "CHECK_FRIENDS_SCORE_FINAL"
		            		facebook.login( appId, listener, {"publish_actions"} )
		            	end
		            end


	            elseif facebookQuery == "CHECK_FRIENDS_SCORE_FINAL" then
	            	print("facebookQuery: CHECK_FRIENDS_SCORE_FINAL")
	            	response = json.decode( event.response )
	            	local data = response.data

	            	if data ~= nil then
		            	--for i = 1, #data, 1 do
		            	for i, v in ipairs(data) do
			            	local name = data[i].user.name
		        			local id = data[i].user.id
		        			local score = data[i].score
		        			table.insert(friendsScore, {name, id, score})
		        		end
		        	end

	            	if friendsScore == nil or myScore == nil then
	            		facebookQuery = "CHECK_FRIENDS_SCORE"
	            		facebook.login( appId, listener, {"publish_actions"} )
	            	else
	            		print("score is ##")
		            	print(friendsScore[1].score)
		            	print("sizeofdata: " .. #friendsScore)

		            	print("myScore is ##")
		            	print(myScore[1].score)
		            	print("sizeofmyScore: ".. #myScore)

	            		local options = {
		            		effect = "fade",
		            		time = 800,
		            		params = {
		            			friendsInformation = friendsScore,
		            			myScoreInformation = myScore
		            		}
		            	}
		            	if not changedToNextScene then
		            		storyboard.gotoScene("leaderboard-scene", options)
		            		changedToNextScene = true
		            	end
	            	end
	            	
	            elseif facebookQuery == "UPDATE_USER_SCORE" then
	            	print("facebookQuery: UPDATE_USER_SCORE")
	            	print(response) -- should return true

	            elseif facebookQuery == "POST_A_PICTURE" then
	            	print("facebookQuery: POST_A_PICTURE")
	            
	            elseif facebookQuery == "LOGOUT" then
	            	print("facebookQuery: LOGOUT")
	            	facebook.logout()

	            else
	            	-- do nothing

	            end

	        else
	        	print("something wrong with request: " .. facebookQuery)
	        	native.showAlert("Conenction Failed!", "Please check your network connection and try again later!", {"OK"});
	        	return	-- exit
	        end


	    elseif ( "dialog" == event.type ) then
	        print( "dialog", event.response )

	    end
	end

	if ( appId ) then
		facebook.logout()
	    facebook.login( appId, listener, {"publish_actions"} )
	else
	    native.showAlert( "Error", "To develop for Facebook Connect, you need to get an application id from Facebook's website.", { "Learn More" }, onComplete )
	end

end
