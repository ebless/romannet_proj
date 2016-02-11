require 'rubygems'
require 'nokogiri'
require 'active_support/core_ext/hash/conversions'
require 'todoist_client'

TodoistClient.api_token = '966cd60f2e8d48f9850ff37f36c12cde715e9eb6'

class Assignment
	
	attr_reader :assigned_for
	attr_reader :type
	attr_reader :details
	attr_reader :due_date

	def initialize(assigned_for, type, details, due_date)
		@assigned_for = assigned_for
		@type = type
		@details = details
		@due_date = due_date
	end
	def convert_project_id
		if @assigned_for == "Middle East (sem 2) - 326S.1"
			@assigned_for = '162513934'
		elsif @assigned_for == "Hon Accel Precalc and Diff Calc - 8420Y.1"
			@assigned_for = '133260729'
		elsif @assigned_for == 'Hon French 4 - 442Y.1'
			@assigned_for = '133260730'
		elsif @assigned_for == 'Comp Sci Principles 2: Applications (sem 2) - 6012S.1'
			@assigned_for = '162881191'
		elsif @assigned_for == 'English 10 - 220Y.1'
			@assigned_for = '133260726'
		end
	end
end

page = Nokogiri::HTML(open('/Users/ebless/Desktop/assignment_center.html'))

assignments = page.css('#assignment-center-assignment-items')
assignments.search('br').each do |i|
	i.remove
end

rows = []

assignments.css('tr').each do |i|
	rows << i
end

tasks = []

rows.each do |i|
	row_hash = Hash.from_xml(i.to_s)
	info = row_hash['tr']['td']
	nodes = page.search('i')
	nodes.each {|node| node.replace(node.content)}
	details = info[2]
	if details.class == String
		details = details.strip
	else
		details_text = details['a']
		details_link = i.css('a').first.attr('href')
		if details_text.class == Hash
			details_text = details_text['div']
		end
		details = "[#{details_text}](#{details_link})"
		puts details
		
	end
	tasks << Assignment.new(info[0], info[1], details, info[4])
end

TodoistClient::Project.all.each do |i|
	i.uncompleted_items.each do |k|
		k.delete
	end
end


tasks.each do |i|
	i.convert_project_id
	item = TodoistClient::Item.create(content: i.details, project_id: i.assigned_for, date_string: i.due_date)
	puts [item.id, item.content]
	item.save
end




