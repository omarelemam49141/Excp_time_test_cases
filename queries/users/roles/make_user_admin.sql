-- Grant Admin role (AbpUserRoles) to a user by email.
-- JWT is issued at login: user must log out and log in after this runs.
-- Default target: o.emam@excp.sa

DECLARE @Email NVARCHAR(256) = N'o.emam@excp.sa';
DECLARE @RoleName NVARCHAR(64) = N'Admin';

-- peek first
SELECT u.Id, u.Email, u.UserName, r.Name AS RoleName
FROM AbpUsers u
LEFT JOIN AbpUserRoles ur ON ur.UserId = u.Id
LEFT JOIN AbpRoles r ON r.Id = ur.RoleId
WHERE u.Email = @Email;

-- add Admin if missing
INSERT INTO AbpUserRoles (UserId, RoleId, TenantId)
SELECT u.Id, r.Id, NULL
FROM AbpUsers u
CROSS JOIN AbpRoles r
WHERE u.Email = @Email
  AND r.Name = @RoleName
  AND NOT EXISTS (
      SELECT 1
      FROM AbpUserRoles ur
      WHERE ur.UserId = u.Id
        AND ur.RoleId = r.Id
  );

-- confirm
SELECT u.Email, r.Name AS RoleName
FROM AbpUsers u
JOIN AbpUserRoles ur ON ur.UserId = u.Id
JOIN AbpRoles r ON r.Id = ur.RoleId
WHERE u.Email = @Email;
