function h = shm_robot(teamNumber, playerID)
% function create the same struct as the team message from
% shared memory. for local debugging use

  h.teamNumber = teamNumber;
  h.playerID = playerID;
  h.user = getenv('USER');

  % create shm wrappers
  h.gcmTeam = shm(sprintf('gcmTeam%d%d%s', h.teamNumber, h.playerID, h.user));
  h.wcmRobot = shm(sprintf('wcmRobot%d%d%s', h.teamNumber, h.playerID, h.user));
  h.wcmBall = shm(sprintf('wcmBall%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmImage = shm(sprintf('vcmImage%d%d%s', h.teamNumber, h.playerID, h.user));

  % set function pointers
  h.update = @update;
  h.get_team_struct = @get_team_struct;
  h.get_monitor_struct = @get_monitor_struct;
  h.get_yuyv = @get_yuyv;
  h.get_rgb = @get_rgb;
  h.get_labelA = @get_labelA;
  h.get_labelB = @get_labelB;

  function update(vargin)
    % do nothing
  end
  
  function r = get_team_struct()
  % returns the robot struct (in the same form as the team messages)
    r = [];
    try
      r.teamNumber = h.gcmTeam.get_number();
      r.teamColor = h.gcmTeam.get_color();
      r.id = h.gcmTeam.get_player_id();
      r.role = h.gcmTeam.get_role();

      pose = h.wcmRobot.get_pose();
      r.pose = struct('x', pose(1), 'y', pose(2), 'a', pose(3));

      ballxy = h.wcmBall.get_xy();
      ballt = h.wcmBall.get_t();
      r.ball = struct('x', ballxy(1), 'y', ballxy(2), 't', ballt);
    catch
    end
  end

  function r = get_monitor_struct()
  % returns the monitor struct (in the same form as the monitor messages)
    r = [];
    try
      r.teamNumber = h.gcmTeam.get_number();
      r.teamColor = h.gcmTeam.get_color();
      r.id = h.gcmTeam.get_player_id();
      r.role = h.gcmTeam.get_role();

      pose = h.wcmRobot.get_pose();
      r.pose = struct('x', pose(1), 'y', pose(2), 'a', pose(3));

      ballxy = h.wcmBall.get_xy();
      ballt = h.wcmBall.get_t();
      r.ball = struct('x', ballxy(1), 'y', ballxy(2), 't', ballt);
    catch
    end
  end

  function yuyv = get_yuyv()
  % returns the raw YUYV image
    width = h.vcmImage.get_width();
    height = h.vcmImage.get_height();
    rawData = h.vcmImage.get_yuyv();
    yuyv = raw2yuyv(rawData, width, height);
  end

  function rgb = get_rgb()
  % returns the raw RGB image (not full size)
    yuyv = h.get_yuyv();
    rgb = yuyv2rgb(yuyv);
  end

  function labelA = get_labelA()
  % returns the labeled image
    width = h.vcmImage.get_width()/2;
    height = h.vcmImage.get_height()/2;
    rawData = h.vcmImage.get_labelA();
    labelA = raw2label(rawData, width, height);
  end

  function labelB = get_labelB()
  % returns the bit-ored labeled image
    width = h.vcmImage.get_width()/2/4;
    height = h.vcmImage.get_height()/2/4;
    rawData = h.vcmImage.get_labelB();
    labelB = raw2label(rawData, width, height);
  end
end

