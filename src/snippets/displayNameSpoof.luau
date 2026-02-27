workspace.ChildAdded:Connect(function(a0: Instance)
    if not shared.fucjkaroind then
    local humanoid = a0:WaitForChild("Humanoid", 5) :: Humanoid
    humanoid.DisplayName = "I need more bullets sir!"
    end
end)