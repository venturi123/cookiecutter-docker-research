#!/usr/bin/env python3
import requests
import json
import re
import os
import sys


def get_latest_nvidia_tag():
    """Get the latest PyTorch container tag from NVIDIA NGC"""
    print("Getting the latest PyTorch container tag from NVIDIA NGC...")
    
    try:
        url = "https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch/tags"
        response = requests.get(url)
        
        print(f"Response status code: {response.status_code}")
        if response.status_code != 200:
            print(f"Request failed with status code: {response.status_code}")
            return None
        
        # Look for tags in the page content
        all_tags = re.findall(r'\b(\d+\.\d+-py3)\b', response.text)
        py3_tags = [tag for tag in all_tags if re.match(r"^\d+\.\d+-py3$", tag)]
        
        if not py3_tags:
            print("No matching tags found")
            return None
            
        # Sort by version to get latest
        latest_tag = sorted(py3_tags, key=lambda x: [int(n) for n in x.split("-")[0].split(".")])[-1]
        print(f"Latest tag found: {latest_tag}")
        return latest_tag
        
    except Exception as e:
        print(f"Error getting tag: {e}")
        return None

def update_cookiecutter_json(tag):
    """Update the tag in cookiecutter.json file"""
    cookiecutter_file = "cookiecutter.json"
    
    if not os.path.exists(cookiecutter_file):
        print(f"Error: File not found {cookiecutter_file}")
        return False
    
    try:
        with open(cookiecutter_file, 'r') as f:
            data = json.load(f)
        
        current_tag = data.get("nvidia_docker_tag", "")
        print(f"Current tag: {current_tag}")
        
        if current_tag == tag:
            print("Tag is already up to date")
            return False
        
        data["nvidia_docker_tag"] = tag
        
        with open(cookiecutter_file, 'w') as f:
            json.dump(data, f, indent=4)
        
        print(f"Updated tag to {tag} in {cookiecutter_file}")
        return True
        
    except Exception as e:
        print(f"Error updating file: {e}")
        return False


if __name__ == "__main__":
    latest_tag = get_latest_nvidia_tag()

    if not latest_tag:
        print("Failed to get latest tag")
        sys.exit(1)
    
    updated = update_cookiecutter_json(latest_tag)
    
    if updated:
        print("Update successful!")
        sys.exit(0)
    else:
        print("No update needed or update failed")
        sys.exit(0) 