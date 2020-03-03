#/bin/bash
sed '1d' /etc/userdomains > tmpfile
input="tmpfile"
while IFS= read -r line; do
	domain=`echo $line | cut -d ":" -f1`
	user=`echo $line | cut -d " " -f2`
	echo -e "Check Username \"$user\" and Domain \"$domain\" LetsEncrypt ..."
	if curl -s -XPOST -d "fqdn=$domain" https://checkhost.unboundtest.com/checkhost | grep -q 'needs renewal'
	then
		echo -e "Domain \"$domain\" needs renewal because it is affected by the Let's Encrypt CAA rechecking problem.\n"
		uapi --user=$user SSL delete_ssl domain=$domain
		/usr/local/cpanel/bin/autossl_check--user=$user
	else
		echo -e "The certificate currently available on \"$domain\" is OK.\n"
	fi
done < "$input"
rm -rf tmpfile
