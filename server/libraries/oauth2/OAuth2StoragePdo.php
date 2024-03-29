<?php

/**
 * @file
 * Sample OAuth2 Library PDO DB Implementation.
 */

require __DIR__ . '/OAuth2.php';
require __DIR__ . '/IOAuth2Storage.php';
require __DIR__ . '/IOAuth2GrantCode.php';
require __DIR__ . '/IOAuth2RefreshTokens.php';

/**
 * PDO storage engine for the OAuth2 Library.
 * 
 * IMPORTANT: This is provided as an example only. In production you may implement
 * a client-specific salt in the OAuth2StoragePDO::hash() and possibly other goodies.
 * 
 *** The point is, use this as an EXAMPLE ONLY. ***
 */
class OAuth2StoragePDO implements IOAuth2GrantCode, IOAuth2RefreshTokens {
	
	/**
	 * Change this to something unique for your system
	 * @var string
	 */
	const SALT = 'blue salt';
	
	/**@#+
	 * Centralized table names
	 * 
	 * @var string
	 */
	const TABLE_CLIENTS = 'clients';
	const TABLE_CODES = 'auth_codes';
	const TABLE_TOKENS = 'access_tokens';
	const TABLE_REFRESH = 'refresh_tokens';
	/**@#-*/
	
	/**
	 * @var PDO
	 */
	private $db;

	/**
	 * Implements OAuth2::__construct().
	 */
	public function __construct(PDO $db) {
		
		try {
			$this->db = $db;
		} catch (PDOException $e) {
			die('Connection failed: ' . $e->getMessage());
		}
	}

	/**
	 * Release DB connection during destruct.
	 */
	function __destruct() {
		$this->db = NULL; // Release db connection
	}

	/**
	 * Handle PDO exceptional cases.
	 */
	private function handleException($e) {
		echo 'Database error: ' . $e->getMessage();
		exit();
	}

	/**
	 * Little helper function to add a new client to the database.
	 *
	 * Do NOT use this in production! This sample code stores the secret
	 * in plaintext!
	 *
	 * @param $client_id
	 * Client identifier to be stored.
	 * @param $client_secret
	 * Client secret to be stored.
	 * @param $redirect_uri
	 * Redirect URI to be stored.
	 */
	public function addClient($client_id, $client_secret, $redirect_uri) {
		try {
//			$client_secret = $this->hash($client_secret, $client_id);
			
			$sql = 'INSERT INTO ' . self::TABLE_CLIENTS . ' (app_name, client_id, client_secret, redirect_uri) VALUES (:app_name, :client_id, :client_secret, :redirect_uri)';
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':app_name', $client_id, PDO::PARAM_STR);
//			$stmt->bindParam(':client_id', $client_id, PDO::PARAM_STR);
			$stmt->bindParam(':client_id', $this->hash($client_secret, $client_id), PDO::PARAM_STR);
			$stmt->bindParam(':client_secret', $client_secret, PDO::PARAM_STR);
			$stmt->bindParam(':redirect_uri', $redirect_uri, PDO::PARAM_STR);
			$stmt->execute();
		} catch (PDOException $e) {
			$this->handleException($e);
		}
	}

	/**
	 * Implements IOAuth2Storage::checkClientCredentials().
	 *
	 */
	public function checkClientCredentials($client_id, $client_secret = NULL) {
		try {
			$sql = 'SELECT client_secret FROM ' . self::TABLE_CLIENTS . ' WHERE client_id = :client_id';
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':client_id', $client_id, PDO::PARAM_STR);
			$stmt->execute();
			
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
			
			if ($client_secret === NULL) {
				return $result !== FALSE;
			}
			
			return $this->checkPassword($client_secret, $result['client_secret'], $client_id);
		} catch (PDOException $e) {
			$this->handleException($e);
		}
	}

	/**
	 * Implements IOAuth2Storage::getRedirectUri().
	 */
	public function getClientDetails($client_id) {
		try {
			$sql = 'SELECT redirect_uri FROM ' . self::TABLE_CLIENTS . ' WHERE client_id = :client_id';
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':client_id', $client_id, PDO::PARAM_STR);
			$stmt->execute();
			
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
			
			if ($result === FALSE) {
				return FALSE;
			}
			
			return isset($result['redirect_uri']) && $result['redirect_uri'] ? $result : NULL;
		} catch (PDOException $e) {
			$this->handleException($e);
		}
	}

	/**
	 * Implements IOAuth2Storage::getAccessToken().
	 */
	public function getAccessToken($oauth_token){ return $this->getToken($oauth_token, FALSE); }

	/**
	 * Implements IOAuth2Storage::setAccessToken().
	 */
	public function setAccessToken($oauth_token, $client_id, $user_id, $expires, $scope = NULL){ $this->setToken($oauth_token, $client_id, $user_id, $expires, $scope, FALSE); }

	/**
	 * @see IOAuth2Storage::getRefreshToken()
	 */
	public function getRefreshToken($refresh_token){ return $this->getToken($refresh_token, TRUE); }

	/**
	 * @see IOAuth2Storage::setRefreshToken()
	 */
	public function setRefreshToken($refresh_token, $client_id, $user_id, $expires, $scope = NULL){ return $this->setToken($refresh_token, $client_id, $user_id, $expires, $scope, TRUE); }

	/**
	 * @see IOAuth2Storage::unsetRefreshToken()
	 */
	public function unsetRefreshToken($refresh_token) {
		try {
			$sql = 'DELETE FROM ' . self::TABLE_TOKENS . ' WHERE refresh_token = :refresh_token';
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':refresh_token', $refresh_token, PDO::PARAM_STR);
			$stmt->execute();
		} catch (PDOException $e) {
			$this->handleException($e);
		}
	}

	/**
	 * Implements IOAuth2Storage::getAuthCode().
	 */
	public function getAuthCode($code) {
		try {
			$sql = 'SELECT code, client_id, user_id, redirect_uri, expires, scope FROM ' . self::TABLE_CODES . ' auth_codes WHERE code = :code';
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':code', $code, PDO::PARAM_STR);
			$stmt->execute();
			
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
			
			return $result !== FALSE ? $result : NULL;
		} catch (PDOException $e) {
			$this->handleException($e);
		}
	}

	/**
	 * Implements IOAuth2Storage::setAuthCode().
	 */
	public function setAuthCode($code, $client_id, $user_id, $redirect_uri, $expires, $scope = NULL) {
		try {
			$sql = 'INSERT INTO ' . self::TABLE_CODES . ' (code, client_id, user_id, redirect_uri, expires, scope) VALUES (:code, :client_id, :user_id, :redirect_uri, :expires, :scope)';
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':code', $code, PDO::PARAM_STR);
			$stmt->bindParam(':client_id', $client_id, PDO::PARAM_STR);
			$stmt->bindParam(':user_id', $user_id, PDO::PARAM_STR);
			$stmt->bindParam(':redirect_uri', $redirect_uri, PDO::PARAM_STR);
			$stmt->bindParam(':expires', $expires, PDO::PARAM_INT);
			$stmt->bindParam(':scope', $scope, PDO::PARAM_STR);
			
			$stmt->execute();
		} catch (PDOException $e) {
			$this->handleException($e);
		}
	}

	/**
	 * @see IOAuth2Storage::checkRestrictedGrantType()
	 */
	public function checkRestrictedGrantType($client_id, $grant_type) {
		return TRUE; // Not implemented
	}

	/**
	 * Creates a refresh or access token
	 * 
	 * @param string $token - Access or refresh token id
	 * @param string $client_id
	 * @param mixed $user_id
	 * @param int $expires
	 * @param string $scope
	 * @param bool $isRefresh
	 */
	protected function setToken($token, $client_id, $user_id, $expires, $scope, $isRefresh = TRUE)
    {
		try
        {        
			$tableName = $isRefresh ? self::TABLE_REFRESH : self::TABLE_TOKENS;
			$tokenName = $isRefresh ? 'refresh_token' : 'oauth_token';
            
			$sql = "INSERT INTO $tableName ($tokenName, client_id, user_id, expires, scope) VALUES (:$tokenName, :client_id, :user_id, :expires, :scope)";
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':' . $tokenName, $token, PDO::PARAM_STR);
			$stmt->bindParam(':client_id', $client_id, PDO::PARAM_STR);
			$stmt->bindParam(':user_id', $user_id, PDO::PARAM_STR);
			$stmt->bindParam(':expires', $expires, PDO::PARAM_INT);
			$stmt->bindParam(':scope', $scope, PDO::PARAM_STR);
			
//            echo print_r($stmt, true);
            
			$eres = $stmt->execute();
            
//            echo print_r($eres, true) . "\n";
//            echo print_r($stmt->errorCode(), true) . "\n";
//            echo print_r($stmt->errorInfo(), true) . "\n";
		}
        catch( PDOException $e )
        {
			$this->handleException($e);
		}
	}

	/**
	 * Retrieves an access or refresh token.
	 * 
	 * @param string $token
	 * @param bool $refresh
	 */
	protected function getToken($token, $isRefresh = true) {
		try
        {
			$tableName = $isRefresh ? self::TABLE_REFRESH : self::TABLE_TOKENS;
			$tokenName = $isRefresh ? 'refresh_token' : 'oauth_token';
			
			$sql = "SELECT $tokenName, client_id, expires, scope, user_id FROM $tableName WHERE $tokenName = :token";
			$stmt = $this->db->prepare($sql);
			$stmt->bindParam(':token', $token, PDO::PARAM_STR);
			$stmt->execute();
			
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
			
			return $result !== FALSE ? $result : NULL;
		}
        catch( PDOException $e )
        {
			$this->handleException($e);
		}
	}

	/**
	 * Change/override this to whatever your own password hashing method is.
	 * 
	 * In production you might want to a client-specific salt to this function. 
	 * 
	 * @param string $secret
	 * @return string
	 */
	protected function hash($client_secret, $client_id) {
		return hash('sha1', $client_id . $client_secret . "lotus salt");
	}

	/**
	 * Checks the password.
	 * Override this if you need to
	 * 
	 * @param string $client_id
	 * @param string $client_secret
	 * @param string $actualPassword
	 */
	protected function checkPassword($try, $client_secret, $client_id) {
		return $try == $this->hash($client_secret, $client_id);
	}
}
