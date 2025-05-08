const puppeteer = require('puppeteer');
const fs = require('node:fs');

async function getBinCollectionDates(houseNumber, postcode) {
  const browser = await puppeteer.launch({
      headless: true,
      // args: ['--single-process', '--no-zygote', '--no-sandbox']
  });
  const page = await browser.newPage();

  await page.goto('https://www.sholland.gov.uk/mycollections', {
    waitUntil: 'networkidle0',
  });

  // Fill in the address details
  await page.type('input[name="SHDCWASTECOLLECTIONS_PAGE1_BUILDING"]', houseNumber);
  await page.type('input[name="SHDCWASTECOLLECTIONS_PAGE1_POSTCODENEW"]', postcode);

  // Click the Find Address button
  await Promise.all([
    page.click('input[value="Find Address"]'),
        page.waitForNavigation({ waitUntil: 'networkidle0' })
  ]);


  // find the content of the two divs...
  const rubbish   = await page.$eval('.general', el => el.innerText);
  const recycling = await page.$eval('.mixed', el => el.innerText);
  await browser.close();

  return { rubbish: rubbish, recycling: recycling };
}

async function saveResult(resp, outputfile) {
    console.log(resp);
    fs.writeFileSync(outputfile, JSON.stringify(resp));
}

const [ house, postcode, outputfile ] = process.argv.slice(2);
console.log(`Write rubbish collection dates for '${house}', '${postcode}' into ${outputfile}`);
getBinCollectionDates(house, postcode)
  .then(resp => saveResult(resp, outputfile))
  .catch(err => console.error('Error:', err));

