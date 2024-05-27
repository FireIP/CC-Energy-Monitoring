local fcp = {}

local function packet(t, s, a, d)
	local p = {type=t, seq=s, ack=a, dat=d}
	return p
end

local function requeueEvent(event)
	os.queueEvent(event[1], event[2], event[3], event[4], event[5], event[6])
end

function fcp.bind(localCh, a, timeout, n)
	local self = {}

	self.connected = false
	self.localCH = localCh
	self.myAktSeq = math.random(0, 255)

	a.open(self.localCH)

	function self.listen(timeout)
		if timeout > 0 then
			self.timer = os.startTimer(timeout)
		end
		self.event = {os.pullEvent()}
		if self.event[1] == "modem_message" and self.event[3] == self.localCH and event[5].type == "SYN" then
			self.remAktSeq = event[5].seq + 1
			a.transmit(self.remoteCh, self.localCH, packet("SYN-ACK", self.remAktSeq, self.myAktSeq))
			self.myAktSeq = self.myAktSeq + 1

			self.event = {os.pullEvent()}
			if self.event[1] == "modem_message" and self.event[3] == self.localCH and self.event[5].type == "ACK" and self.event[5].ack == self.myAktSeq then
				self.connected = true
				return true
			elseif self.event[1] == "modem_message" then
				self.event2 = {os.pullEvent()}
				if self.event2[1] == "modem_message" and self.event2[3] == self.localCH and self.event2[5].type == "ACK" and self.event2[5].ack == self.myAktSeq then
					self.connected = true
					return true
				elseif self.event2[1] == "modem_message" then
					os.cancelTimer(self.timer)
					requeueEvent(self.event)
					requeueEvent(self.event2)
					return false
					
				end
			end
		end
	end

	return self
end

function fcp.open(localCh, remoteCh, a, timeout, n)
	local self = {}

	self.connected = false

	self.localCH = localCh
	self.remoteCh = remoteCh

	a.open(self.localCH)


	self.myAktSeq = math.random(0, 255)
	a.transmit(self.remoteCh, self.localCh, packet("SYN", self.myAktSeq))
	self.myAktSeq = self.myAktSeq + 1
	
	if timeout > 0 then
		self.timer = os.startTimer(timeout)
	end

	self.try = 0
	while self.try <= n do
		self.event = {os.pullEvent()}
		if event[1] == "modem_message" and event[3] == self.localCH and event[5].type == "SYN-ACK" and event[5].ack == self.myAktSeq then
			os.cancelTimer(self.timer)
			self.remAktSeq = event[5].seq +1
			
			a.transmit(self.remoteCh, self.localCH, packet("ACK", self.myAktSeq, self.remAktSeq))
			self.myAktSeq = self.myAktSeq + 1
			--ESTABLISHED--
			self.connected = true

		elseif event[1] == "timer" then
			self.try = self.try + 1
			if self.try >= n then
				error("socket timeout retry: " .. self.try, 1)
			end
		end
	end
	

	function self.write(s, timeout)
		a.transmit(self.remoteCh, self.localCh, packet("DAT", self.myAktSeq))
		self.myAktSeq = self.myAktSeq + 1

		if timeout > 0 then
			sefl.timer = os.startTimer(timeout)
		end
		self.event = {os.pullEvent()}
		if self.event[1] == "modem_message" and self.event[3] == self.localCH and self.event[5].type == "ACK" and self.event[5].ack == self.myAktSeq  then
			os.cancelTimer(self.timer)
			self.remAktSeq = event[5].seq + 1
			return true
		elseif event[1] == "modem_message" then
			self.event2 = {os.pullEvent()}
			if self.event2[1] == "modem_message" and self.event2[3] == self.localCH and self.event2[5].type == "ACK" and self.event2[5].ack == self.myAktSeq  then
				os.cancelTimer(self.timer)
				self.remAktSeq = event[5].seq + 1
				return true
			elseif self.event2[1] == "modem_message" then
				os.cancelTimer(self.timer)
				requeueEvent(self.event)
				requeueEvent(self.event2)
				return false
			elseif self.event2[1] == "timer" then
				requeueEvent(self.event)
				return false
			end
			os.cancelTimer(self.timer)
			requeueEvent(self.event)
			requeueEvent(self.event2)
			return false

		elseif event[1] == "timer" then
			return false
		end
		os.cancelTimer(self.timer)
		requeueEvent(self.event)
		return false
	end

	function self.read(timeout)
		if timeout > 0 then
			self.timer = os.startTimer(timeout)
		end
		self.event = {os.pullEvent()}
		if self.event[1] == "modem_message" and self.event[3] == self.localCH and self.event[5].type == "DAT" then
			os.cancelTimer(self.timer)
			self.remAktSeq = event[5].seq + 1
			a.transmit(self.remoteCh, self.localCH, packet("ACK", self.myAktSeq, self.remAktSeq))
			self.myAktSeq = self.myAktSeq + 1
			return event[5].dat

		elseif event[1] == "modem_message" then
			self.event2 = {os.pullEvent()}
			if self.event2[1] == "modem_message" and self.event2[3] == self.localCH and self.event[5].type == "DAT" then
				os.cancelTimer(self.timer)
				self.remAktSeq = event[5].seq + 1
				a.transmit(self.remoteCh, self.localCH, packet("ACK", self.myAktSeq, self.remAktSeq))
				self.myAktSeq = self.myAktSeq + 1
				return event[5].dat
			elseif self.event2[1] == "modem_message" then
				os.cancelTimer(self.timer)
				requeueEvent(self.event)
				requeueEvent(self.event2)
				return nil
			elseif self.event2[1] == "timer" then
				requeueEvent(self.event)
				return nil
			end
			os.cancelTimer(self.timer)
			requeueEvent(self.event)
			requeueEvent(self.event2)
			return nil
		elseif self.event[1] == "timer" then
			return nil
		end
		os.cancelTimer(self.timer)
		requeueEvent(self.event)
		return nil
	end

	function close()
		a.transmit(self.remoteCh, self.localCH, packet("FIN", self.myAktSeq))
		self.myAktSeq = self.myAktSeq + 1
	end

	return self
end

local function doSleep()
	os.pullEvent("timer")
end
local function handleEvent()
	while true do
		local event = {os.pullEvent("modem_message")}
		requeueEvent(event)
	end
end
function fcp.fsleep(s) --does not consume modem events
	for i = 1, (s*10), 1 do
		os.startTimer(0.1)
		parallel.waitForAny(doSleep, handleEvent)
		
	end
end

return fcp
