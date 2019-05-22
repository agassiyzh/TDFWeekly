#!/usr/bin/env ruby

require "psych"
require "fileutils"

class Membership
  def initialize()
    time = Time.now
    @members = Array.new()
    @week_based_year = time.strftime("%V")
    @year = time.year()

    @template_markdown_path = "template.md"
    begin
      @yaml_conent = Psych.load_file("membership.yaml")
      @template = Psych.load_file("template.yaml")
      @membership = @yaml_conent["membership"]
    rescue Psych::SyntaxError => e
      e.file
      e.message
    end
  end

  def walk_membership
    def member_parser(o, paths = [])
      if o.instance_of? Hash
        o.each do |k, v|
          member_parser(v, paths + [k])
        end
      elsif o.instance_of? Array
        o.each do |item|
          if item.instance_of? Hash
            member_parser(item, paths)
          elsif item.instance_of? Array
          else
            @members.insert(-1, {"name" => item, "path" => "#{@year}/#{@week_based_year}/" + paths.join("/"), "organization" => paths})
          end
        end
      end
    end

    member_parser(@membership)

    uniq_paths = (@members.flat_map { |e| e["path"] }).uniq!

    uniq_paths.each do |path|
      check_and_create_destination_directory(path)
    end

    @members.each do |member|
      filePath = File.join(member["path"], member["name"] + ".yaml")
      member["weekly report content"] = @template
      member["year"] = @year
      member["week"] = @week_based_year
      if !File.exist?(filePath)
        File.open(filePath, "w") do |file|
          file.write(Psych.dump(member))
        end
      end
    end
  end

  def check_and_create_destination_directory(directroy_path)
    FileUtils.mkdir_p(directroy_path) unless File.directory?(directroy_path)
  end
end

Membership.new.walk_membership
